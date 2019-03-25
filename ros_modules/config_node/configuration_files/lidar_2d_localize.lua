-- this relies on the file cartographer_turtlebot/caonfiguration_files/turtlebot_urg_lidar_2d.lua
-- see also other files in cartographer_ros/configuration_files for examples
-- more docs on the configuration: https://google-cartographer-ros.readthedocs.io/en/latest/configuration.html

include "lidar_2d.lua"


TRAJECTORY_BUILDER_2D.max_range = 10.
TRAJECTORY_BUILDER_2D.missing_data_ray_length = 9.5

-- set the pure localization using an existing map.
TRAJECTORY_BUILDER.pure_localization_trimmer = {
  max_submaps_to_keep = 3 -- 2 min
}
-- TRAJECTORY_BUILDER.collate_fixed_frame=false
TRAJECTORY_BUILDER_2D.submaps.num_range_data = 60

-- https://docs.ros.org/api/cartographer/html/overlapping__submaps__trimmer__2d_8h_source.html


-- the higher these values, the faster
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight=1e1 --e3 -- 50 --default 10. the higher, the more relevance is given to odom?
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight=1e1 --e2

POSE_GRAPH.constraint_builder.sampling_ratio=0.3 -- 0.3 default
POSE_GRAPH.constraint_builder.max_constraint_distance=5.0 --default 15 Threshold for poses to be considered near a submap.
POSE_GRAPH.constraint_builder.min_score=0.9 --default 0.55 Threshold for the scan match score below which a match is not considered. Low scores indicate that the scan and map do not look similar.
 

-- teleporting, global localization
POSE_GRAPH.global_sampling_ratio = 0.003
POSE_GRAPH.global_constraint_search_after_n_seconds=10
POSE_GRAPH.constraint_builder.global_localization_min_score=0.99

-- tune for latency
MAP_BUILDER.num_background_threads=2
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight=5 --10 --default 10. the higher, the more relevance is given to odom?
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight=20 --40 --default 40, same for rotation
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.use_nonmonotonic_steps=false --default false
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.num_threads=2
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.max_num_iterations=20


return options
