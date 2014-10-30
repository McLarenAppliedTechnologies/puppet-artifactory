class artifactory($jdk = "java-1.7.0-openjdk",
  $source = "http://downloads.sourceforge.net/project/artifactory/artifactory",
  $artifact = "artifactory-powerpack-rpm",
  $s3_sourced = false,
  $version = "3.4.1") {

  if ! defined (Package[$jdk]) {
    package { $jdk: ensure => installed }
  }

  if $s3_sourced {
    $sourced_rpm = "/tmp/$artifact-$version.rpm"
  } else {
    $sourced_rpm = "$source/$artifact-$version.rpm"
  }

  exec { "fetch-from-s3":
      path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
      command => "/usr/bin/s3cmd --force --config /root/.s3cfg get $source/$artifact-$version.rpm",
      cwd     => "/tmp",
      unless  => "test $s3_sourced = 'false'"
  }
  ->
  package { 'artifactory':
    ensure => installed,
    provider => "rpm",
    source => "$sourced_rpm",
    require => Package[$jdk]
  }

  service { 'artifactory':
    ensure    => 'running',
    enable => "true",
    hasstatus => "true",
    provider => "redhat",
    require => Package['artifactory']
  }
}