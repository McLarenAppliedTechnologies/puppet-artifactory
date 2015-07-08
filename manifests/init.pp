class artifactory($jdk = "java-1.7.0-openjdk",
  $source = "https://bintray.com/artifact/download/jfrog/artifactory-rpms",
  $artifact = "artifactory",
  $s3_sourced = false,
  $version = "3.9.2",
  $behind_proxy = false) {

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

  file { '/var/opt/jfrog/artifactory/tomcat/conf/Catalina/localhost/artifactory.xml':
    ensure  => file,
    content => template('artifactory/artifactory.xml.erb'),
    mode    => '0775',
    owner   => root,
    group   => root,
    require => Package['artifactory'],
    notify  => Service['artifactory'],
  }

  service { 'artifactory':
    ensure    => 'running',
    enable => "true",
    hasstatus => "true",
    provider => "redhat",
    require => Package['artifactory']
  }

}
