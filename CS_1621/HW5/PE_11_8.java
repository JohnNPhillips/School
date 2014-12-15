import java.util.ArrayList;
import java.util.List;

/* 
 * Write an abstract data type for a queue whose elements include both
 * a 20-character string and an integer priority. This queue must have
 * the following methods: enqueue, which takes a string and an integer
 * as parameters; dequeue, which returns the string from the queue that
 * has the highest priority; and empty. The queue is not to be
 * maintained in priority order of its elements, so the dequeue
 * operation must always search the whole queue.
 */

public class PriorityQueue
{
	private List<String> dataList = new ArrayList<String>();
	private List<Integer> prioList = new ArrayList<Integer>();
	
	public void enqueue(String data, int prio)
	{
		dataList.add(data);
		prioList.add(prio);
	}
	
	public void empty()
	{
		dataList.clear();
		prioList.clear();
	}
	
	public String dequeue()
	{
		if (dataList.isEmpty())
		{
			return null;
		}
		
		int maxIndex = 0;
		for (int i = 1; i < prioList.size(); i++)
		{
			if (prioList.get(i) > prioList.get(maxIndex))
			{
				maxIndex = i;
			}
		}
		
		prioList.remove(maxIndex);
		return dataList.remove(maxIndex);
	}
}
