"""
 *
 * This file is part of rasdaman community.
 *
 * Rasdaman community is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Rasdaman community is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU  General Public License for more details.
 *
 * You should have received a copy of the GNU  General Public License
 * along with rasdaman community.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2003 - 2016 Peter Baumann / rasdaman GmbH.
 *
 * For more information please see <http://www.rasdaman.org>
 * or contact Peter Baumann via <baumann@rasdaman.com>.
 *
"""
from abc import ABCMeta, abstractmethod
from services import executor, linux_distro
from helper.log import log
from helper.prompt import ChangeSeverity, user_confirmed_change
from helper.stringutil import replace_in_list
from helper.distrowrapper import DistroTypes, DistroWrapper
from tpinstaller import TPInstallerBasis, UserCreationInstaller, MainPathInstaller, \
    DebPackageInstaller, PipInstaller, PathInstaller, TomcatInstaller, PackagerInstall, \
    EpelRepoInstaller, RpmPackageInstaller, PostgresqlCentOsInstaller, \
    LdconfigInstall, UpdateJavaAlternativesInstaller, \
    CustomCmakeInstaller


class OSInstaller:
    """
    Wraps installation details specific to a particular OS version.
    """
    __metaclass__ = ABCMeta

    def install(self):
        self.validate()
        self.get_deps().install()

    def get_packages(self, profile):
        packages = self.get_build_packages()
        if not profile.build_only:
            packages += self.get_run_packages()
        return packages

    def get_build_packages(self):
        """
        Returns a list of packaged that are needed to build rasdaman for this OS
        :rtype: list[str]
        """
        ret = self.get_build_core_packages()
        if self.profile.petascope_enabled:
            ret += self.get_build_java_packages()
        if self.profile.build_cmake:
            ret += self.get_build_cmake_packages()
        elif self.profile.build_autotools:
            ret += self.get_build_autotools_packages()
        if self.profile.packaging:
            ret += self.get_packaging_packages()
        return ret

    @abstractmethod
    def get_build_core_packages(self):
        """
        Returns the core packages needed to build rasdaman
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_build_java_packages(self):
        """
        Returns the java packages needed to build the java code
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_build_autotools_packages(self):
        """
        Returns the packages needed to build rasdaman with autotools
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_build_cmake_packages(self):
        """
        Returns the packages needed to build rasdaman with cmake
        :rtype: list[str]
        """
        pass

    def get_run_packages(self):
        """
        Returns a list of packages that are needed only when running rasdaman
        :rtype: list[str]
        """
        ret = self.get_run_core_packages()
        if self.profile.petascope_enabled:
            if self.profile.petascope_type == "tomcat":
                # tomcat will automatically pull the needed java package
                ret += self.get_run_tomcat_packages()
            else:
                ret += self.get_run_java_packages()
        if self.profile.test_systemtest:
            ret += self.get_run_systemtest_packages()
        return ret

    @abstractmethod
    def get_run_core_packages(self):
        """
        Returns the core packages needed to run rasdaman
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_run_java_packages(self):
        """
        Returns the java packages needed to run the java code
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_run_pip_packages(self):
        """
        Returns packages needed to be installed with pip
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_run_systemtest_packages(self):
        """
        Returns packages needed to be installed for running the systemtest
        :rtype: list[str]
        """
        pass

    def get_run_tomcat_packages(self):
        """
        Returns Tomcat packages
        :rtype: list[str]
        """
        return [linux_distro.get_tomcat_name()]

    @abstractmethod
    def get_packaging_packages(self):
        """
        Returns packages needed for building rasdaman packages
        :rtype: list[str]
        """
        pass

    @abstractmethod
    def get_deps(self):
        """
        Returns the tp dependencies
        :rtype: TPInstaller
        """
        pass

    @abstractmethod
    def validate(self):
        """
        Validates the operating system and warns user if he has to do some action
        that this script can't do for him
        """
        pass

    def get_extra_autotools_options(self):
        """
        Returns extra autotools options
        :rtype: list[str]
        """
        return []


class Debian8TPInstaller(OSInstaller):
    def __init__(self, profile):
        """
        Installs the Debian dependencies, the defaults are based on Debian 8
        :param Profile profile: installation profile
        """
        self.profile = profile

    def get_build_core_packages(self):
        return ['make', 'libtool', 'gawk', 'autoconf',
                'bison', 'flex', 'git', 'g++', 'unzip', 'libboost-all-dev',
                'libtiff-dev', 'libgdal-dev', 'zlib1g-dev', 'libffi-dev',
                'libnetcdf-dev', 'libedit-dev', 'libreadline-dev', 'libecpg-dev',
                'libsqlite3-dev', 'libgrib-api-dev', 'libgrib2c-dev', 'curl'
                ]

    def get_build_cmake_packages(self):
        return ['cmake', 'ccache']

    def get_build_autotools_packages(self):
        return ['automake', 'autotools-dev', 'm4']

    def get_build_java_packages(self):
        return ['openjdk-7-jdk', 'maven', 'ant']

    def get_run_core_packages(self):
        return ['postgresql', 'postgresql-contrib', 'sqlite3', 'zlib1g',
                'gdal-bin', 'python-dev', 'debianutils',
                'python-dateutil', 'python-lxml', 'python-grib', 'python-pip',
                'python-gdal', 'libnetcdf-dev', 'netcdf-bin', 'libnetcdfc++4', 'libecpg6',
                'libboost-all-dev', 'libedit-dev', 'python-netcdf', 'libreadline-dev'
                ]

    def get_run_java_packages(self):
        return ['openjdk-7-jre']

    def get_run_pip_packages(self):
        return ['glob2']

    def get_run_systemtest_packages(self):
        return ['bc', 'vim-common']

    def get_packaging_packages(self):
        return ['ruby-dev', 'ruby']

    def get_deps(self):
        """
        Returns all the dependencies for rasdaman on Debian
        """
        deps = TPInstallerBasis()
        if self.profile.third_party_package_install:
            deps = DebPackageInstaller(deps, self.get_packages(self.profile))
        deps = UserCreationInstaller(deps, self.profile.user, self.profile.main_path)
        if not self.profile.build_only:
            deps = PipInstaller(deps, self.get_run_pip_packages())
        deps = MainPathInstaller(deps, self.profile.main_path)
        deps = PathInstaller(deps, self.profile.install_path, self.profile.database_data_directory)
        if self.profile.petascope_type == "tomcat" and not self.profile.build_only and not self.profile.osgeo:
            deps = TomcatInstaller(deps)
        if self.profile.packaging:
            deps = PackagerInstall(deps)
        deps = LdconfigInstall(deps)
        if self.profile.build_cmake:
            deps = CustomCmakeInstaller(deps)
        return deps

    def validate(self):
        pass


class Debian7TPInstaller(Debian8TPInstaller):
    def __init__(self, profile):
        """
        TP Installer for Debian 7. Due to a bug in ant package we need to do extra work.
        :param Profile profile: the installation profile
        """
        super(Debian7TPInstaller, self).__init__(profile)

    def get_deps(self):
        deps = super(Debian7TPInstaller, self).get_deps()
        deps = UpdateJavaAlternativesInstaller(deps)
        return deps

    def get_build_cmake_packages(self):
        """
        cmake version < 3
        """
        return []


class Ubuntu1404TpInstaller(Debian8TPInstaller):
    def __init__(self, profile):
        """
        TP Installer for Ubuntu 14.04
        :param Profile profile: the installation profile
        """
        super(Ubuntu1404TpInstaller, self).__init__(profile)

    def get_build_cmake_packages(self):
        """
        cmake version < 3
        """
        return []

    def get_packaging_packages(self):
        """
        We need ruby >= 2 to install fpm. The below packages are in a separate PPA
        ppa:brightbox/ruby-ng, which is added by the DebPackageInstaller prior to
        installing them.
        """
        return ['ruby2.0-dev', 'ruby2.0']


class Ubuntu1510TpInstaller(Debian8TPInstaller):
    def __init__(self, profile):
        """
        TP Installer for Ubuntu 15.10
        :param Profile profile: the installation profile
        """
        super(Ubuntu1510TpInstaller, self).__init__(profile)

    def get_build_java_packages(self):
        return ['openjdk-8-jdk', 'maven', 'ant']

    def get_run_java_packages(self):
        return ['openjdk-8-jre']

    def get_build_core_packages(self):
        ret = super(Ubuntu1510TpInstaller, self).get_build_core_packages()
        ret = replace_in_list(ret, 'libnetcdf-dev', 'libnetcdf-cxx-legacy-dev')
        return ret

    def get_run_core_packages(self):
        ret = super(Ubuntu1510TpInstaller, self).get_run_core_packages()
        ret = replace_in_list(ret, 'libnetcdfc++4', 'libnetcdf-c++4')
        ret = replace_in_list(ret, 'python-netcdf', 'python-netcdf4')
        return ret

    def get_run_pip_packages(self):
        return ['glob2']


class Ubuntu1604TpInstaller(Ubuntu1510TpInstaller):
    def __init__(self, profile):
        """
        TP Installer for Ubuntu 16.04
        :param Profile profile: the installation profile
        """
        super(Ubuntu1604TpInstaller, self).__init__(profile)


class Ubuntu1610TpInstaller(Ubuntu1604TpInstaller):
    def __init__(self, profile):
        """
        TP Installer for Ubuntu 16.10
        :param Profile profile: the installation profile
        """
        super(Ubuntu1610TpInstaller, self).__init__(profile)


class CentOS7TPInstaller(OSInstaller):
    def __init__(self, profile):
        """
        Installs the CentOS 7 dependencies
        :param Profile profile: installation profile
        """
        self.profile = profile
        self.needs_repo = False

    def get_build_core_packages(self):
        return ['make', 'libtool', 'autoconf', 'bison', 'flex', 'flex-devel', 'git', 'curl',
                'gcc', 'gcc-c++', 'unzip', 'boost-devel', 'libstdc++-static',
                'libtiff-devel', 'gdal-devel', 'zlib-devel', 'libedit-devel', 'readline-devel',
                'netcdf-cxx-devel', 'netcdf-devel', 'postgresql-devel',
                'sqlite-devel', 'openssl-devel', 'grib_api-devel', 'hdf-devel'
                ]

    def get_build_cmake_packages(self):
        """
        cmake version < 3
        """
        return []

    def get_build_autotools_packages(self):
        return ['automake']

    def get_build_java_packages(self):
        return ['java-1.8.0-openjdk-devel', 'maven', 'ant']

    def get_run_core_packages(self):
        """
        Note: gcc and grib_api-devel are needed in order to 'pip install pygrib'
        """
        return ['postgresql-server', 'postgresql-contrib', 'sqlite', 'zlib', 'boost',
                'gdal', 'netcdf', 'netcdf-cxx', 'libtiff', 'libedit', 'readline', 'openssl',
                'gcc', 'python-devel', 'python-dateutil', 'python-magic', 'which',
                'python-lxml', 'python-pip', 'python-setuptools', 'grib_api',
                'gdal-python', 'pyproj', 'netcdf4-python', 'hdf', 'grib_api-devel',
                'sysvinit-tools'
                ]

    def get_run_java_packages(self):
        return ['java-1.8.0-openjdk']

    def get_run_pip_packages(self):
        return ['glob2', 'pygrib']

    def get_run_systemtest_packages(self):
        return ['bc', 'vim-common']

    def get_packaging_packages(self):
        return ['ruby-devel', 'ruby', 'rpm-build']

    def get_deps(self):
        """
        Returns all the dependencies for rasdaman on CentOS
        """
        deps = TPInstallerBasis()
        if self.needs_repo:
            deps = EpelRepoInstaller(deps)
        if self.profile.third_party_package_install:
            deps = RpmPackageInstaller(deps, self.get_packages(self.profile))
        deps = UserCreationInstaller(deps, self.profile.user, self.profile.main_path)
        if not self.profile.build_only:
            deps = PipInstaller(deps, self.get_run_pip_packages())
        deps = MainPathInstaller(deps, self.profile.main_path)
        deps = PathInstaller(deps, self.profile.install_path, self.profile.database_data_directory)
        if not self.profile.build_only:
            deps = PostgresqlCentOsInstaller(deps, self.profile.petascope_database_conf_user)
        if self.profile.petascope_type == "tomcat" and not self.profile.build_only:
            deps = TomcatInstaller(deps)
        if self.profile.packaging:
            deps = PackagerInstall(deps)
        deps = LdconfigInstall(deps)
        if self.profile.build_cmake:
            deps = CustomCmakeInstaller(deps)
        return deps

    def validate(self):
        if not self.profile.build_package:
            repolist, _, _ = executor.executeSudo(["yum", "repolist"])
            if "epel" not in repolist:
                self.needs_repo = True
                if not self.profile.unorthodox_changes:
                    log.error("You need to enable EPEL repository before the installation can continue. "
                              "We can do this for you if you set unorthodox_changes to true in the profile file.")
                    exit(1)

    def get_extra_autotools_options(self):
        return ["LDFLAGS=-L/usr/lib64/hdf/", "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/hdf/"]


class OSNotSupported(Exception):
    def __init__(self, os_name):
        """
        Error that occurs when we do not know how to deal with the given OS
        :param str os_name: the os name
        """
        self.os_name = os_name

    def __str__(self):
        return "Your Linux distro could not be detected or is not supported. Found distro name: " + self.os_name


class OSVersionNotSupported(Exception):
    def __init__(self, os_name, os_version):
        """
        Error that occurs when we do not support the given OS version
        :param str os_name: the os name
        :param str os_version: the os version
        """
        self.os_name = os_name
        self.os_version = os_version

    def __str__(self):
        return self.os_name + " version " + self.os_version + " is not supported."


class OSDependeciesInstallerFactory:
    @staticmethod
    def get_deps_installer_for_os(profile):
        """
        Returns the OS installer based on the OS name and version.
        :param Profile profile: installation profile
        :rtype: OSInstaller
        """
        distro = DistroWrapper()
        if distro.distro_type == DistroTypes.DEBIAN:
            if distro.distro_version < 7:
                raise OSVersionNotSupported(distro.distro_name, distro.distro_version)
            elif distro.distro_version < 8:
                return Debian7TPInstaller(profile)
            else:
                return Debian8TPInstaller(profile)
        elif distro.distro_type == DistroTypes.UBUNTU:
            if distro.distro_version < 14.04:
                raise OSVersionNotSupported(distro.distro_name, distro.distro_version)
            elif distro.distro_version < 15.10:
                return Ubuntu1404TpInstaller(profile)
            elif distro.distro_version < 16.10:
                return Ubuntu1604TpInstaller(profile)
            else:
                return Ubuntu1610TpInstaller(profile)
        elif distro.distro_type == DistroTypes.CENTOS:
            if distro.distro_version < 7:
                raise OSVersionNotSupported(distro.distro_name, distro.distro_version)
            else:
                return CentOS7TPInstaller(profile)
        else:
            raise OSNotSupported(distro.distro_name)
