#!c:/Perl/bin/Perl.exe

## 规定命令行参数：
## filepath：文件路径 D:/logs
## date：日期yy.mm.dd

my $path="D:/logs"; ## 默认路径
if(scalar(@ARGV)>0){
	if(scalar(@ARGV)==1){  ## 只输入一个参数 
		if($ARGV[0] !~ /^([a-zA-Z]:(\/|\\)\w+)/ && $ARGV[0] !~ /\d{4}\.\d{2}\.\d{2}/ ){
			print '请输入正确的文件路径或日期格式！例如 D:/logs 或 yy.mm.dd';
			exit;
		}
		if($ARGV[0] =~ /^([a-zA-Z]:(\/|\\)\w+)/ ){
			&compress($ARGV[0],"");
		}elsif($ARGV[0] =~ /\d{4}\.\d{2}\.\d{2}/){
			&compress($path,$ARGV[0]);
		}
	}else{					## 第一个参数为文件路径，第二个参数为日期
		if($ARGV[0] !~ /^([a-zA-Z]:(\/|\\)\w+)/){
			print '请输入正确的文件路径！例如 D:/logs';
			exit;
		}
		if($ARGV[1] !~ /\d{4}\.\d{2}\.\d{2}/){
			print '请输入正确的日期格式！例如 yy.mm.dd';
			exit;
		}
		&compress($ARGV[0],$ARGV[1]);
	}
}else{
	&compress($path,"");
}

## 压缩文件 jf@2018/3/29
## $path: 文件路径
## $date: 指定日期
sub compress {
	my ($path,$date) = @_;
	$path =~ s/^\s+//; $date =~ s/^\s+//;
	$path =~ s/\s+$//; $date =~ s/\s+$//;
	my $diff_day;
	if($date ne ""){
		use Time::Local;
		my ($year,$mon,$day) =split(/\./,$date);
		$diff_day = timelocal(0,0,0,$day,$mon-1, $year);
	}else{
		$diff_day=time();
	}
	if (opendir(DIR, $path)){
		print "文件路径$path开始：\r\n";
		foreach (grep(!/^\.\.?$/,readdir(DIR))) {		## 过滤掉Windows默认'.'、'..'
			my @property = stat("$path/$_");			## stat函数获取文件信息 	
			if ($property[2]==16895) {					## 文件夹，递归压缩
				&compress("$path/$_");		
			}else{
				if ($_ =~ /^.*(\d{4}-?\d{2}-?\d{2}).*(log|txt)$/i && (($diff_day-$property[9]) > 86400)){		## 压缩条件（日期无精确匹配）
					my $archive_file="$path/$_";
					my $archive_filename=substr($_,0,-3);
					$archive_filename=$path."/".$archive_filename."rar";
					use Archive::Rar;
					my $rar =new Archive::Rar();		## 详情参考 http://search.cpan.org/~smueller/Archive-Rar-2.02/lib/Archive/Rar.pm
					## donotoverwrite 参数为真表示不覆盖已存在的压缩包，而是往存在的压缩包新增待压缩文件。
					my $ret=$rar->Add(
						-archive => $archive_filename,
						-files => $archive_file,
						-quiet=>false,
						-donotoverwrite=>1,
					);
					if ($ret==0){
						print "文件$path/$_压缩成功并删除原文件\r\n";
						unlink("$path/$_");
					}else{
						print "文件$path/$_压缩失败\r\n";
					}
				}else{
					print "文件$path/$_不符合压缩条件\r\n";
				}			
			}
		}
		closedir(DIR);
	}
}

