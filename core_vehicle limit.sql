


INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
('mechanic_tools', 'Mechanic Tools', 1, 0, 1),
('toolbox', 'Tool Box', 1, 0, 1),
('turbo_lvl_1', 'GARET Turbo', 1, 0, 1),
('race_transmition', 'Race Transmition', 1, 0, 1),
('race_suspension', 'Race Suspension', 1, 0, 1),
('v8engine', 'V8 Engine', 1, 0, 1),
('2jzengine', '2JZ Engine', 1, 0, 1),
('michelin_tires', 'Michelin Tires', 1, 0, 1),
('race_brakes', 'Race Breaks', 1, 0, 1);


CREATE TABLE `vehicle_parts` (
  `id` int(11) NOT NULL,
  `plate` varchar(100) NOT NULL,
  `parts` longtext NOT NULL,
  `mileage` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
