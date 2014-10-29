class artifactory($jdk = "java-1.7.0-openjdk",
  $source = "http://downloads.sourceforge.net/project/artifactory/artifactory",
  $artifact = "artifactory" ,
  $version = "3.4.1") {

  if ! defined (Package[$jdk]) {
    package { $jdk: ensure => installed }
  }

  package { 'artifactory':
    ensure => installed,
    provider => "rpm",
    source => "$source/$artifact-$version.rpm",
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
