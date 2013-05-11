#include "mymalloc.h"

void *my_worstfit_malloc(int size)
{
	if (base == (void *)-1)
	{
		base = (void *)sbrk(0);
	}
	
	size += size % 4 ? 4 - (size % 4) : 0; // Align size to 4 byte boundary
	int requiredSize = size + 2 * sizeof(int);
	
	void *largestBlock = NULL;
	int largestSize = -1;

	void *blockStart = base;
	while (blockStart < sbrk(0)) // Find largest free area in the heap
	{
		int blockLength = *(int *)blockStart & 0xFFFFFFFE;
		
		if ((*(int *)blockStart & 0x00000001) == 0)
		{
			if (blockLength > largestSize)
			{
				largestSize = blockLength;
				largestBlock = blockStart;
			}
		}
		
		blockStart += blockLength;
	}
	
	if (largestSize >= requiredSize)
	{
		if (largestSize - requiredSize < 8)
		{
			requiredSize = largestSize;
		}
		
		if (largestSize == requiredSize)
		{
			blockStart = largestBlock;
		}
		else
		{
			blockStart = largestBlock;
			int freeSpace = largestSize - requiredSize;
			void *freeBlock = blockStart + requiredSize;
			*(int *)freeBlock = freeSpace;
			*(int *)(freeBlock + freeSpace - 4) = freeSpace;
		}
	}
	else
	{
		blockStart = (void *)sbrk(0);
		sbrk(requiredSize);
	}
	
	*(int *)blockStart = requiredSize | 0x00000001;
	*(int *)(blockStart + requiredSize - 4) = requiredSize | 0x00000001;
	
	return blockStart + 4;
}

void my_free(void *ptr)
{
	void *blockStart = ((int *)ptr) - 1;
	*(int *)blockStart &= 0xFFFFFFFE; // Set low bit to 0 in header
	
	int blockLength= *(int *)blockStart;
	*(int *)(blockStart + blockLength - 4) &= 0xFFFFFFFE; // Set low bit to 0 in footer
	
	// Coalesce with previous block
	if (blockStart > base)
	{
		void *lastBlockEnd = blockStart - 4;
		if ((*(int *)lastBlockEnd & 0x00000001) == 0) // last block free
		{
			int lastBlockSize = *(int *)lastBlockEnd;
			void *lastBlockStart = blockStart - lastBlockSize;
			*(int *)lastBlockStart = lastBlockSize + blockLength;
			*(int *)(blockStart + blockLength - 4) = lastBlockSize + blockLength;
			
			blockStart = lastBlockStart;
			blockLength += lastBlockSize;
		}
	}
	
	// Coalesce with next block
	if ((int)blockStart + blockLength < (int)sbrk(0))
	{
		void *nextBlockStart = blockStart + blockLength;
		if ((*(int *)nextBlockStart & 0x00000001) == 0) // next block free
		{
			int nextBlockSize = *(int *)nextBlockStart;
			void *nextBlockEnd = nextBlockStart + nextBlockSize - 4;
			*(int *)blockStart = blockLength + nextBlockSize;
			*(int *)nextBlockEnd = blockLength + nextBlockSize;
			
			blockLength += nextBlockSize;
		}
	}
	else
	{
		// Shrink heap if it is the last block of memory
		sbrk(-blockLength);
	}
}
