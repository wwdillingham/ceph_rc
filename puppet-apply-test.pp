$mon_hosts = ['mon01.rc.fas.harvard.edu', 'mon02.rc.fas.harvard.edu', 'mon03.rc.fas.harvard.edu']
$mds_hosts = ['mds01.rc.fas.harvard.edu']
$osd_hosts = ['osd01-afterhyphen.rc.fas.harvard.edu', 'osd02-afterhyphen.rc.fas.harvard.edu', 'osd03-afterhyphen.rc.fas.harvard.edu']
$numreplicas = "3"
$pools = ['poola', 'poolb']
file { '/tmp/mytestfile.txt':
  ensure => present,
  content => template('/Users/wesd/repos/ceph_rc/create_ceph_cluster.sh.erb')
}
