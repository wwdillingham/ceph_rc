$mons = ['mon01', 'mon02', 'mon03']
$mdss = ['mds01']
$osdss = ['osd01', 'osd02', 'osd03']
file { '/tmp/mytestfile.txt':
  ensure => present,
  content => template('/Users/wesd/repos/ceph_rc/create_ceph_cluster.sh.erb')
}
