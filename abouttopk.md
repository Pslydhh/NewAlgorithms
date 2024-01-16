Assume it is order by XXXX limit N.

Before optimization, for each batch of data DataSegments (approximately more than 20 million rows), we will filter out the first Nv rows from DataSegmenst, and then perform a merge-sort operation with N0 (the first N rows that existed before), and get A brand new N0 for the next batch of operations.

After optimization, our entire process remains unchanged. Before filtering out Nv rows in DataSegmenst, generally speaking, we first use the previous batch of data N0[first, end] to do two filterings:

Use end to filter out the data < end from DataSegmenst and record it as DataSegmenst2. Generally speaking, DataSegmenst2 is much less than DataSegmenst.
Then use first to filter out the data < first from DataSegmenst2 and record it as DataSegment3, and the remaining part is recorded as DataSegmenst2.
We sort parts DataSegment3 and DataSegmenst2 respectively.
In the merge-sort stage, DataSegment3 is now in the front as a whole. We use DataSegmenst2 and N0 to perform the merge-sort operation as needed to get the merge-result, and finally splice [DataSegment3, merge-result] to get the new N0.
After optimization, the original process remains unchanged from an implementation perspective, and the number of basic chunks is changed to 3,000. For each batch of data (approximately more than 12 million rows), _build_sorting_data, _filter_and_sort_data_by_row_cmp, and _merge_sort_data_as_merged_segment are called in sequence:
Premise: _init_merged_segment is false, which means it is the first batch of data, and N0 does not exist at this moment;
||||||||||| _init_merged_segment is true, which means it is not the first batch of data, and N0 exists at this moment.

_build_sorting_data: Construct segments for the entire batch. If _init_merged_segment is false, construct permutations.second for the entire batch; if _init_merged_segment is true, do nothing.
_filter_and_sort_data_by_row_cmp: If _init_merged_segment is false, filter out the top N key data from permutations.second. At this moment, permutations.first is empty, and permutations.second contains the top N key data. If _init_merged_segment is true, obtain the first and last pieces of data in N0, first and end. First filter with end in segments, then filter with first in the results, and get permutations based on the results of the two filterings (filter_array). .first and permutations.second, and then partial data in permutations.first and permutations.second.
_merge_sort_data_as_merged_segment: If _init_merged_segment is false, the first N data in permutations.second will be used as the result _merged_segment. If _init_merged_segment is true, first determine whether there are enough N pieces of data in permutations.first. If so, use permutations.first as the result _merged_segment. Otherwise, use permutations.first to fill the previous part of the new _merged_segment (the length is recorded as size), and then start from permutations. Second and _merged_segment perform merge-sort to obtain N-size pieces of data as the latter part of the new _merged_segment. In this way, a brand new _merged_segment is obtained.
_merged_segment as the topn result up to this batch.
Since we are doing calculations with a batch of data (datasegments), the data structure used in the implementation process is also in the form of an array.
