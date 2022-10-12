FROM ubuntu:18.04
MAINTAINER Frank Stettner <frank-stettner@gmx.net>

ENV DEBIAN_FRONTEND noninteractive
ENV BASE_DIR /opt
# AppImage related setting
ENV APPIMAGE_EXTRACT_AND_RUN 1
ENV ARCH i386
# Qt 5.12 settings
ENV QT_BASE_DIR /opt/qt512
ENV QTDIR $QT_BASE_DIR
ENV PATH $QT_BASE_DIR/bin:$PATH
ENV LD_LIBRARY_PATH $QT_BASE_DIR/lib/i386-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH $QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get upgrade -y \
	# Install basic stuff
	&& apt-get install -y --no-install-recommends \
		sudo bash apt-utils software-properties-common \
		wget ca-certificates gnupg2 unzip bzip2 lzip sed \
	# Install build stuff
	&& apt-get install -y --no-install-recommends \
		gcc g++ make autoconf autoconf-archive automake libtool \
		gcc-multilib g++-multilib pkg-config check doxygen swig \
	# Install libserialport, libsigrok and smuview dependencies
	&& apt-get install -y --no-install-recommends \
		libglib2.0-dev:i386 libglibmm-2.4-dev:i386 \
		libzip-dev:i386 libusb-1.0-0-dev:i386 libftdi1-dev:i386 libhidapi-dev:i386 \
		libbluetooth-dev:i386 libvisa-dev:i386 nettle-dev:i386 \
		libavahi-client-dev:i386 libieee1284-3-dev:i386 \
		libboost1.65-dev:i386 \
	#
	# Update certificates
	&& update-ca-certificates \
	#
	# Install current git
	&& add-apt-repository -y ppa:git-core/ppa \
	&& apt-get update \
	&& apt-get install -y git \
	#
	# Install current cmake
	&& wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
	&& apt-key add kitware-archive-latest.asc \
	&& apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main' \
	&& apt-get update \
	&& apt-get install -y kitware-archive-keyring \
	&& apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA \
	&& apt-get install -y cmake \
	#
	# Install Qt 5.12 from beineri PPA
	&& sudo add-apt-repository -y ppa:beineri/opt-qt-5.12.10-bionic \
	&& sudo apt-get update \
	&& apt-get install -y --no-install-recommends \
		qt512base:i386 qt512svg:i386 \
	#
	# Install Qwt 6.1.6
	&& apt-get install -y mesa-common-dev:i386 libgl1-mesa-dev:i386 \
	&& cd /opt \
	&& wget https://sourceforge.net/projects/qwt/files/qwt/6.1.6/qwt-6.1.6.tar.bz2 \
	&& tar xf qwt-6.1.6.tar.bz2 \
	&& cd qwt-6.1.6 \
	&& export QMAKESPEC=linux-g++-32 \
	&& qmake qwt.pro \
	&& make \
	# Change the QWT_INSTALL_PREFIX in qwtconfig.pri to /usr
	&& sed -i 's|^\([[:space:]]*QWT_INSTALL_PREFIX[[:space:]]*=[[:space:]]*\)/usr.*$|\1/usr|g' qwtconfig.pri \
	&& make install \
	# Cleanup
	&& cd .. \
	&& rm qwt-6.1.6.tar.bz2 \
	&& rm -rf qwt-6.1.6 \
	#
	# Cleanup apt
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*