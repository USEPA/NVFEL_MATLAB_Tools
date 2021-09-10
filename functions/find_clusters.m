function [cluster_centers] = find_clusters( in, threshold)

% if nargin < 2
% 	min_cluster_size = 1;
% end

in_sort = sort(in(:));

in_diff = diff( in_sort);

in_range = in_sort(end) - in_sort(1);

if nargin < 2
	threshold = max( 0.03, 0.5 / sqrt( numel(in_sort)));
end


cluster = ones(size(in_sort));
c_idx = 1;
max_score = 1;
while max_score > threshold
	
	% Find largest gap in cluster
	[~,gap_idx] = max(in_diff .* (cluster(2:end) == c_idx) .* (cluster(1:end-1) == c_idx) );
	
	after_pts = (1:length(in_sort))' > gap_idx ;
	
	cluster(after_pts) = cluster(after_pts) + 1;
	
	
	% [cluster, in_sort, [in_diff;0]]
	cluster_score = [];
	for c = max(cluster):-1:1
		pts = cluster == c;
		gaps = [0;diff(in_sort(pts))];
% 		cluster_score(c) = 0.1*sum(pts) ./ length(in_sort) + 0.3*( max( in_sort(pts)) - min(in_sort(pts)))./ in_range + 0.6 * max(gaps )./in_range;
		cluster_score(c) = 0.35*( max( in_sort(pts)) - min(in_sort(pts)))./ in_range + 0.65 * max(gaps )./in_range;
		
	end
	
	
	[max_score, c_idx] = max( cluster_score );
	
	
end



for c = 1:max(cluster)
	pts = cluster == c;
	cluster_centers(c) = (mean( in_sort( pts)) + median(in_sort( pts)))/2 ;
end


end
