-- documented current configuration params:
-- https://github.com/googlecartographer/cartographer/blob/master/docs/source/configuration.rst
-- all possible and default configuratoin params:
-- https://github.com/googlecartographer/cartographer/tree/master/configuration_files



include "map_builder.lua"
-- its this file: https://github.com/googlecartographer/cartographer/blob/master/configuration_files/trajectory_builder.lua
include "trajectory_builder.lua"
-- it defines the variable MAP_BUILDER and loads both: 
-- include "trajectory_builder_2d.lua"
-- located here: https://github.com/googlecartographer/cartographer/blob/master/configuration_files/trajectory_builder_2d.lua


options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map", --    The ROS frame ID to use for publishing submaps, the parent frame of poses, usually
  tracking_frame = "imu_link", --imu_link works with gazebo. The ROS frame ID of the frame that is tracked by the SLAM algorithm. If an IMU is used, it should be at its position, although it might be rotated. A common choice is Ã¢â‚¬Å“imu_linkÃ¢â‚¬.
  published_frame = "odom", -- odom worked, base_link would be same as in the backpack_2d.lua example. The ROS frame ID to use as the child frame for publishing poses. For example Ã¢â‚¬Å“odomÃ¢â‚¬ if an Ã¢â‚¬Å“odomÃ¢â‚¬ frame is supplied by a different part of the system. In this case the pose of Ã¢â‚¬Å“odomÃ¢â‚¬ in the map_frame will be published. Otherwise, setting it to Ã¢â‚¬Å“base_linkÃ¢â‚¬ is likely appropriate.
  odom_frame = "odom_augmented", --Only used if provide_odom_frame is true. The frame between published_frame and map_frame to be used for publishing the (non-loop-closed) local SLAM result. Usually Ã¢â‚¬Å“odomÃ¢â‚¬.
  provide_odom_frame = false, -- 
  publish_frame_projected_to_2d = false,
  use_odometry = true,
  use_nav_sat = false,
  use_landmarks = true,
  num_laser_scans = 1,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 0,
  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 0.02, --was 2e-3
  trajectory_publish_period_sec = 1e-1, --  was 30e-3
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.0,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1., -- what does it mean? Do we have to publish empty landmarks at 10hz?
}

-- map build config https://github.com/googlecartographer/cartographer/blob/master/configuration_files/map_builder.lua
MAP_BUILDER.use_trajectory_builder_2d = true
MAP_BUILDER.num_background_threads=2

TRAJECTORY_BUILDER.pure_localization_trimmer = {
  max_submaps_to_keep = 993,
}

-- TRAJECTORY_BUILDER.collate_fixed_frame=false

-- see algorithmic tuning
-- https://github.com/googlecartographer/cartographer_ros/blob/master/docs/source/algo_walkthrough.rst

TRAJECTORY_BUILDER_2D.num_accumulated_range_data = 1 --default 19
TRAJECTORY_BUILDER_2D.min_range = 0.41
TRAJECTORY_BUILDER_2D.submaps.grid_options_2d.resolution=0.05 -- default 0.05
TRAJECTORY_BUILDER_2D.max_range = 10.
TRAJECTORY_BUILDER_2D.missing_data_ray_length = 9.5
TRAJECTORY_BUILDER_2D.voxel_filter_size = 0.025 --default: 0.025
TRAJECTORY_BUILDER_2D.use_imu_data = false -- imu is kaputt
TRAJECTORY_BUILDER_2D.use_online_correlative_scan_matching = false
TRAJECTORY_BUILDER_2D.adaptive_voxel_filter = {
  max_length = 0.3,
  min_num_points = 100,
  max_range = 10.,

}


-- see for default values: trajectory_builder_2d.lua#L41
-- ignores a scan if the estimated motion (by the scan matcher) is below these values
TRAJECTORY_BUILDER_2D.motion_filter.max_angle_radians = math.rad(1.2) --Threshold above which range data is inserted based on rotational motion.
TRAJECTORY_BUILDER_2D.motion_filter.max_distance_meters=0.5 --default 0.2

-- weight on the pose extrapolation as prior input to ceres scan matcher
-- TRAJECTORY_BUILDER_2D.ceres_scan_matcher.occupied_space_weight=20. --default 20
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight=1 --10 --default 10. the higher, the more relevance is given to odom?
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight=1 --40 --default 40, same for rotation
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.use_nonmonotonic_steps=false --default false
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.num_threads=2
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.max_num_iterations=100

--store the world as tsdf
TRAJECTORY_BUILDER_2D.submaps.num_range_data = 60 --100 see https://google-cartographer-ros.readthedocs.io/en/latest/tuning.html#correct-size-of-submaps
TRAJECTORY_BUILDER_2D.submaps.grid_options_2d.grid_type= "TSDF" -- default PROBABILITY_GRID
--set this to the same type
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.range_data_inserter_type="TSDF_INSERTER_2D"

-- TRAJECTORY_BUILDER_2D.collate_landmarks = false  -- if landmarks are used, set this to false

-- if probability grid was used to store data
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.hit_probability=0.75
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.miss_probability=0.49
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.insert_free_space=true

-- if tsdf is used to store the submap data
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.tsdf_range_data_inserter.truncation_distance=0.40 --default 0.3
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.tsdf_range_data_inserter.update_free_space=true --default false
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.tsdf_range_data_inserter.project_sdf_distance_to_scan_normal=true --true -- default false
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.tsdf_range_data_inserter.maximum_weight=2 --default 10
-- pose graph options: 
-- https://github.com/googlecartographer/cartographer/blob/master/configuration_files/pose_graph.lua

POSE_GRAPH.optimize_every_n_nodes = 3 --2. 

-- POSE_GRAPH.overlapping_submaps_trimmer_2d = {
--   fresh_submaps_count = 1,
--   min_covered_area = 2, --default 2
--   min_added_submaps_count = 5 --default 5
-- }

POSE_GRAPH.global_sampling_ratio = 0.003 -- 0.0 means loop closing is disabled
POSE_GRAPH.global_constraint_search_after_n_seconds=1e10 --e29 -- deactivated default 10


-- how much do we trust the odometry?
POSE_GRAPH.optimization_problem.local_slam_pose_translation_weight=1e9 --default 1e5
POSE_GRAPH.optimization_problem.local_slam_pose_rotation_weight=1e9 --default 1e5
POSE_GRAPH.optimization_problem.odometry_translation_weight=1e5 --default 1e5
POSE_GRAPH.optimization_problem.odometry_rotation_weight=1e5 -- default 1e5
POSE_GRAPH.optimization_problem.huber_scale = 2e3 -- 0.5e1

POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.linear_search_window = 7.0 --default 7
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.angular_search_window = math.rad(30.0) -- default 30
POSE_GRAPH.matcher_translation_weight=5e2 --default 5e2
POSE_GRAPH.matcher_rotation_weight=1.6e3  -- default 1.6e3

POSE_GRAPH.constraint_builder.sampling_ratio=0.03 -- 0.3 default
POSE_GRAPH.constraint_builder.max_constraint_distance=3.0 --default 15 Threshold for poses to be considered near a submap.
POSE_GRAPH.constraint_builder.min_score=0.9 --default 0.55 Threshold for the scan match score below which a match is not considered. Low scores indicate that the scan and map do not look similar.

-- loop closing
POSE_GRAPH.constraint_builder.global_localization_min_score=0.74 -- default 0.65
POSE_GRAPH.constraint_builder.loop_closure_translation_weight=1e9 --e7 -- default 1.1e4
POSE_GRAPH.constraint_builder.loop_closure_rotation_weight=1e9 --default 1e5
POSE_GRAPH.constraint_builder.log_matches=true



return options



