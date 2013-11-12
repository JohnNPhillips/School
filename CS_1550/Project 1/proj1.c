/*
	Counts the number of "0"s and "1"s in an
	input file recursively (through forking)
	
	Usage: ./proj1 <input file>
	Parents timeout in 60 seconds (defined by CHILD_TIMEOUT_SECS) if
	a child fails to send the bit counts over the pipe.
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

#define CHILD_TIMEOUT_SECS 60

#define IS_ERROR_COUNT(bitcounts) (bitcounts.zeros == -1 && bitcounts.ones == -1)
typedef struct bitcount_t
{
	int zeros;
	int ones;
} bitcount_t;

char *procName;

// Adds two bitcounts together and returns the result
bitcount_t addCounts(bitcount_t a, bitcount_t b)
{
	bitcount_t total;
	total.zeros = a.zeros + b.zeros;
	total.ones = a.ones + b.ones;
	
	return total;
}

// Add the given character to the bit counts
void addBit(bitcount_t *count, char bit)
{
	if (bit == '0')
	{
		count->zeros++;
	}
	else if (bit == '1')
	{
		count->ones++;
	}
}

// Forks off a child process and sends it the specified bit string to process
// Returns the pipe file descriptor that the child's response can be read from
int forkAndSendData(char *data, int dataLen)
{
	int pipefd[2];
	if (pipe(pipefd) == -1)
	{
		perror("Error: Could not create pipe to child\n");
		exit(1);
	}
	
	int pid = fork();
	if (pid == -1)
	{
		perror("Error: Could not fork to child\n");
		exit(1);
	}
	else if (pid != 0)
	{
		// Parent //
		
		close(pipefd[1]);
		return pipefd[0];
	}
	else
	{
		// Child //

		dup2(pipefd[1], fileno(stdout));
		
		data[dataLen] = 0; // Terminate data
		execl(procName, procName, data, NULL);
		
		exit(0);
	}
}

// Reads the bit counts back from a child
bool readCounts(int pipefd, bitcount_t *count)
{
	int totalRead = 0;
	do
	{
		int bytesRead = read(pipefd, count + totalRead, sizeof(bitcount_t) - totalRead);
		if (bytesRead <= 0)
		{
			perror("Error: Could not read counts from a child\n");
			return false;
		}
		
		totalRead += bytesRead;
	}
	while (totalRead < sizeof(bitcount_t));
	
	return true;
}

// Waits for a pipe to be readable
// The timeout is defined by the CHILD_TIMEOUT_SECS constant
bool isReadable(int pipefd)
{
	fd_set readSet;
	struct timeval timeout;
	
	FD_ZERO(&readSet);
	FD_SET(pipefd, &readSet);
	timeout.tv_sec = CHILD_TIMEOUT_SECS;
	timeout.tv_usec = 0;
	if (select(pipefd + 1, &readSet, NULL, NULL, &timeout) != 1)
	{
		perror("Error: Could not read counts from pipe - Timed out\n");
		return false;
	}

	return true;
}

// Counts the number of '0' and '1' in a bit string.
// If the string is > 2 character, the processes forks itself
// into two children and sends each one half of the bit string
// to calculate.
bitcount_t bit_count(char *data, int dataLen)
{
	bitcount_t errorCount;
	errorCount.zeros = -1;
	errorCount.ones = -1;
	
	bitcount_t totals;
	memset(&totals, 0, sizeof(bitcount_t));

	if (dataLen == 1 || dataLen == 2)
	{
		// Process is a leaf node (one or two chars given)
		addBit(&totals, data[0]);
		if (dataLen == 2)
		{
			addBit(&totals, data[1]);
		}
	}
	else if (dataLen > 2)
	{
		// Need to fork off into two more processes
		int lenLeft = dataLen / 2;
		int lenRight = dataLen - lenLeft;
		
		int readLeftFD = forkAndSendData(data, lenLeft);
		int readRightFD = forkAndSendData(data + lenLeft, lenRight);
		
		fd_set readSet;
		struct timeval timeout;
		
		// Wait for data from left child with timeout
		if (!isReadable(readLeftFD))
		{
			perror("Error: Could not read counts from left child - Timed out\n");
			return errorCount;
		}
		
		// Read bit counts from pipe
		bitcount_t leftCount;
		if (!readCounts(readLeftFD, &leftCount) || IS_ERROR_COUNT(leftCount))
		{
			perror("Error: Cannot read bit counts from left child\n");
			return errorCount;
		}
		
		// Wait for data from right child with timeout
		if (!isReadable(readRightFD))
		{
			perror("Error: Could not read counts from left child - Timed out\n");
			return errorCount;
		}
		
		// Read bit counts from pipe
		bitcount_t rightCount;
		if (!readCounts(readRightFD, &rightCount) || IS_ERROR_COUNT(rightCount))
		{
			perror("Error: Cannot read bit counts from right child\n");
			return errorCount;
		}
		
		// Close pipes from children
		close(readLeftFD);
		close(readRightFD);
		
		// Add the counts from the two children
		totals = addCounts(leftCount, rightCount);
	}
	
	return totals;
}

// Reads a file into an array of characters and returns the pointer
char *readFile(char *fileName)
{
	FILE *f = fopen(fileName, "r");
	if (f)
	{
		fseek(f, 0, SEEK_END);
		int size = ftell(f);
		fseek(f, 0, SEEK_SET);
		
		char *fileData = (char *)malloc(size + 1);
		if (fileData != NULL)
		{
			if (fread(fileData, 1, size, f) == size)
			{
				fileData[size] = 0; // Terminate string
				
				return fileData;
			}
			
			free(fileData);
		}
	}
	
	return NULL;
}

// Determines whether a string is a bit string (made up of only '0' and '1')
bool isBinString(char *arg)
{
	while (*arg != 0)
	{
		if (*arg != '0' && *arg != '1')
		{
			return false;
		}
		
		arg++;
	}
	
	return true;
}

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		printf("Error: Must pass a file name as an argument\n");
		return 0;
	}
	procName = argv[0];
	
	if (isBinString(argv[1]))
	{
		// Child process
		
		bitcount_t counts = bit_count(argv[1], strlen(argv[1]));
		
		write(fileno(stdout), &counts, sizeof(bitcount_t));
		
		exit(0);
	}
	else
	{
		// Initial parent process
		
		char *fileData = readFile(argv[1]);
		
		if (fileData == NULL)
		{
			printf("Error: Cannot read file\n");
			return 0;
		}
		
		bitcount_t counts = bit_count(fileData, strlen(fileData));
		if (IS_ERROR_COUNT(counts))
		{
			// Error(s) occurred in the child processes
			printf("--------\nThe program encountered errors in its children when executing. Could not aggregate the bit counts successfully.\n--------\n");
		}
		else
		{
			// Successfully obtained result
			printf("Total Zeros: %i\nTotal Ones: %i\n", counts.zeros, counts.ones);
		}
		
		free(fileData);
	}
	return 0;
}
