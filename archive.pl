#!c:/Perl/bin/Perl.exe

## �涨�����в�����
## filepath���ļ�·�� D:/logs
## date������yy.mm.dd

my $path="D:/logs"; ## Ĭ��·��
if(scalar(@ARGV)>0){
	if(scalar(@ARGV)==1){  ## ֻ����һ������ 
		if($ARGV[0] !~ /^([a-zA-Z]:(\/|\\)\w+)/ && $ARGV[0] !~ /\d{4}\.\d{2}\.\d{2}/ ){
			print '��������ȷ���ļ�·�������ڸ�ʽ������ D:/logs �� yy.mm.dd';
			exit;
		}
		if($ARGV[0] =~ /^([a-zA-Z]:(\/|\\)\w+)/ ){
			&compress($ARGV[0],"");
		}elsif($ARGV[0] =~ /\d{4}\.\d{2}\.\d{2}/){
			&compress($path,$ARGV[0]);
		}
	}else{					## ��һ������Ϊ�ļ�·�����ڶ�������Ϊ����
		if($ARGV[0] !~ /^([a-zA-Z]:(\/|\\)\w+)/){
			print '��������ȷ���ļ�·�������� D:/logs';
			exit;
		}
		if($ARGV[1] !~ /\d{4}\.\d{2}\.\d{2}/){
			print '��������ȷ�����ڸ�ʽ������ yy.mm.dd';
			exit;
		}
		&compress($ARGV[0],$ARGV[1]);
	}
}else{
	&compress($path,"");
}

## ѹ���ļ� jf@2018/3/29
## $path: �ļ�·��
## $date: ָ������
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
		print "�ļ�·��$path��ʼ��\r\n";
		foreach (grep(!/^\.\.?$/,readdir(DIR))) {		## ���˵�WindowsĬ��'.'��'..'
			my @property = stat("$path/$_");			## stat������ȡ�ļ���Ϣ 	
			if ($property[2]==16895) {					## �ļ��У��ݹ�ѹ��
				&compress("$path/$_");		
			}else{
				if ($_ =~ /^.*(\d{4}-?\d{2}-?\d{2}).*(log|txt)$/i && (($diff_day-$property[9]) > 86400)){		## ѹ�������������޾�ȷƥ�䣩
					my $archive_file="$path/$_";
					my $archive_filename=substr($_,0,-3);
					$archive_filename=$path."/".$archive_filename."rar";
					use Archive::Rar;
					my $rar =new Archive::Rar();		## ����ο� http://search.cpan.org/~smueller/Archive-Rar-2.02/lib/Archive/Rar.pm
					## donotoverwrite ����Ϊ���ʾ�������Ѵ��ڵ�ѹ���������������ڵ�ѹ����������ѹ���ļ���
					my $ret=$rar->Add(
						-archive => $archive_filename,
						-files => $archive_file,
						-quiet=>false,
						-donotoverwrite=>1,
					);
					if ($ret==0){
						print "�ļ�$path/$_ѹ���ɹ���ɾ��ԭ�ļ�\r\n";
						unlink("$path/$_");
					}else{
						print "�ļ�$path/$_ѹ��ʧ��\r\n";
					}
				}else{
					print "�ļ�$path/$_������ѹ������\r\n";
				}			
			}
		}
		closedir(DIR);
	}
}

