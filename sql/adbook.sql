CREATE TABLE `adbook` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`email` varchar(255) NOT NULL COMMENT 'メールアドレス',
	`name` varchar(255) NOT NULL COMMENT '名前',
	`gender` enum('male', 'famale') NOT NULL COMMENT '性別',
	`birthday` date NOT NULL COMMENT '誕生日',
	`age` int(11) unsigned NOT NULL COMMENT '年齢',
	`status` enum('1', '0') NOT NULL DEFAULT '1' COMMENT '有効/無効',
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='アドレス帳';
