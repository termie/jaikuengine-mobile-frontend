# This Makefile is for the DJabberd extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.30 (Revision: Revision: 4535 ) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT_FROM => q[lib/DJabberd.pm]
#     AUTHOR => q[Brad Fitzpatrick <brad@danga.com>]
#     EXE_FILES => [q[djabberd]]
#     NAME => q[DJabberd]
#     PREREQ_PM => { Digest::HMAC_SHA1=>q[0], Net::SSLeay=>q[0], XML::SAX=>q[0], Net::DNS=>q[0.48], XML::LibXML::SAX=>q[0], Danga::Socket=>q[1.51], Log::Log4perl=>q[0] }
#     VERSION_FROM => q[lib/DJabberd.pm]

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /System/Library/Perl/5.8.8/darwin-thread-multi-2level/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = ar
CC = cc
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = bundle
DLSRC = dl_dlopen.xs
LD = env MACOSX_DEPLOYMENT_TARGET=10.3 cc
LDDLFLAGS =  -bundle -undefined dynamic_lookup -L/usr/local/lib
LDFLAGS =  -L/usr/local/lib
LIBC = /usr/lib/libc.dylib
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = darwin
OSVERS = 8.9.1
RANLIB = ranlib
SITELIBEXP = /Library/Perl/5.8.8
SITEARCHEXP = /Library/Perl/5.8.8/darwin-thread-multi-2level
SO = dylib
EXE_EXT = 
FULL_AR = /usr/bin/ar
VENDORARCHEXP = /Network/Library/Perl/5.8.8/darwin-thread-multi-2level
VENDORLIBEXP = /Network/Library/Perl/5.8.8


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = DJabberd
NAME_SYM = DJabberd
VERSION = 0.83
VERSION_MACRO = VERSION
VERSION_SYM = 0_83
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.83
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /usr
SITEPREFIX = /usr/local
VENDORPREFIX = /usr
INSTALLPRIVLIB = /System/Library/Perl/5.8.8
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /Library/Perl/5.8.8
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /Network/Library/Perl/5.8.8
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /System/Library/Perl/5.8.8/darwin-thread-multi-2level
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /Library/Perl/5.8.8/darwin-thread-multi-2level
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /Network/Library/Perl/5.8.8/darwin-thread-multi-2level
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /usr/local/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = /usr/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLMAN1DIR = /usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /usr/local/share/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = /usr/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /usr/local/share/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = /usr/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /System/Library/Perl/5.8.8
PERL_ARCHLIB = /System/Library/Perl/5.8.8/darwin-thread-multi-2level
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /System/Library/Perl/5.8.8/darwin-thread-multi-2level/CORE
PERL = /usr/bin/perl
FULLPERL = /usr/bin/perl
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /System/Library/Perl/5.8.8/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.30
MM_REVISION = Revision: 4535 

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = DJabberd
BASEEXT = DJabberd
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/DJabberd.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/DJabberd.pm \
	lib/DJabberd/Component.pm \
	lib/DJabberd/Component/Example.pm \
	lib/DJabberd/Component/External.pm \
	lib/DJabberd/Connection/ComponentIn.pm \
	lib/DJabberd/Connection/ComponentOut.pm \
	lib/DJabberd/Delivery/ComponentConnection.pm \
	lib/DJabberd/Delivery/LocalVHosts.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = ClientIn.pm \
	lib/DJabberd.pm \
	lib/DJabberd/AWS/AsyncHTTP.pm \
	lib/DJabberd/AWS/Authen.pm \
	lib/DJabberd/AWS/Config.pm \
	lib/DJabberd/AWS/RosterStorage.pm \
	lib/DJabberd/AWS/S3.pm \
	lib/DJabberd/Agent.pm \
	lib/DJabberd/Agent/Node.pm \
	lib/DJabberd/Authen.pm \
	lib/DJabberd/Authen/AllowedUsers.pm \
	lib/DJabberd/Authen/InMemoryOnly.pm \
	lib/DJabberd/Authen/StaticPassword.pm \
	lib/DJabberd/Bot.pm \
	lib/DJabberd/Bot/Admin.pm \
	lib/DJabberd/BotContext.pm \
	lib/DJabberd/Callback.pm \
	lib/DJabberd/Cluster.pm \
	lib/DJabberd/ClusterMessage.pm \
	lib/DJabberd/ClusterMessage/DeliverStanza.pm \
	lib/DJabberd/Component.pm \
	lib/DJabberd/Component/Example.pm \
	lib/DJabberd/Component/External.pm \
	lib/DJabberd/Component/Node.pm \
	lib/DJabberd/Connection.pm \
	lib/DJabberd/Connection/Admin.pm \
	lib/DJabberd/Connection/ClientIn.pm \
	lib/DJabberd/Connection/ClusterIn.pm \
	lib/DJabberd/Connection/ClusterOut.pm \
	lib/DJabberd/Connection/ComponentIn.pm \
	lib/DJabberd/Connection/ComponentOut.pm \
	lib/DJabberd/Connection/DialbackVerify.pm \
	lib/DJabberd/Connection/OldSSLClientIn.pm \
	lib/DJabberd/Connection/ServerIn.pm \
	lib/DJabberd/Connection/ServerOut.pm \
	lib/DJabberd/Connection/SimpleIn.pm \
	lib/DJabberd/DNS.pm \
	lib/DJabberd/Delivery.pm \
	lib/DJabberd/Delivery/ComponentConnection.pm \
	lib/DJabberd/Delivery/Local.pm \
	lib/DJabberd/Delivery/LocalVHosts.pm \
	lib/DJabberd/Delivery/S2S.pm \
	lib/DJabberd/DialbackParams.pm \
	lib/DJabberd/HookDocs.pm \
	lib/DJabberd/IQ.pm \
	lib/DJabberd/JID.pm \
	lib/DJabberd/Log.pm \
	lib/DJabberd/Message.pm \
	lib/DJabberd/Plugin.pm \
	lib/DJabberd/Presence.pm \
	lib/DJabberd/PresenceChecker.pm \
	lib/DJabberd/PresenceChecker/Dummy.pm \
	lib/DJabberd/PresenceChecker/Local.pm \
	lib/DJabberd/Queue.pm \
	lib/DJabberd/Queue/ClusterOut.pm \
	lib/DJabberd/Queue/ServerOut.pm \
	lib/DJabberd/Roster.pm \
	lib/DJabberd/RosterItem.pm \
	lib/DJabberd/RosterStorage.pm \
	lib/DJabberd/RosterStorage/InMemoryOnly.pm \
	lib/DJabberd/SAXHandler.pm \
	lib/DJabberd/Stanza.pm \
	lib/DJabberd/Stanza/DialbackResult.pm \
	lib/DJabberd/Stanza/DialbackVerify.pm \
	lib/DJabberd/Stanza/StartTLS.pm \
	lib/DJabberd/Stanza/StreamFeatures.pm \
	lib/DJabberd/Stats.pm \
	lib/DJabberd/StreamStart.pm \
	lib/DJabberd/StreamVersion.pm \
	lib/DJabberd/Subscription.pm \
	lib/DJabberd/TestSAXHandler.pm \
	lib/DJabberd/Util.pm \
	lib/DJabberd/VHost.pm \
	lib/DJabberd/XMLElement.pm \
	lib/DJabberd/XMLParser.pm

PM_TO_BLIB = lib/DJabberd/Component.pm \
	blib/lib/DJabberd/Component.pm \
	lib/DJabberd/JID.pm \
	blib/lib/DJabberd/JID.pm \
	lib/DJabberd/Connection/ClusterOut.pm \
	blib/lib/DJabberd/Connection/ClusterOut.pm \
	lib/DJabberd/Connection/ServerOut.pm \
	blib/lib/DJabberd/Connection/ServerOut.pm \
	lib/DJabberd/Component/Node.pm \
	blib/lib/DJabberd/Component/Node.pm \
	lib/DJabberd/Agent/Node.pm \
	blib/lib/DJabberd/Agent/Node.pm \
	lib/DJabberd/Stanza/StartTLS.pm \
	blib/lib/DJabberd/Stanza/StartTLS.pm \
	lib/DJabberd/Connection/ClusterIn.pm \
	blib/lib/DJabberd/Connection/ClusterIn.pm \
	lib/DJabberd/Connection/Admin.pm \
	blib/lib/DJabberd/Connection/Admin.pm \
	lib/DJabberd/Queue/ClusterOut.pm \
	blib/lib/DJabberd/Queue/ClusterOut.pm \
	lib/DJabberd/Cluster.pm \
	blib/lib/DJabberd/Cluster.pm \
	lib/DJabberd/Stats.pm \
	blib/lib/DJabberd/Stats.pm \
	lib/DJabberd/PresenceChecker.pm \
	blib/lib/DJabberd/PresenceChecker.pm \
	lib/DJabberd/Bot/Admin.pm \
	blib/lib/DJabberd/Bot/Admin.pm \
	lib/DJabberd/Log.pm \
	blib/lib/DJabberd/Log.pm \
	lib/DJabberd/Authen/InMemoryOnly.pm \
	blib/lib/DJabberd/Authen/InMemoryOnly.pm \
	lib/DJabberd/Connection/OldSSLClientIn.pm \
	blib/lib/DJabberd/Connection/OldSSLClientIn.pm \
	lib/DJabberd/Delivery/ComponentConnection.pm \
	blib/lib/DJabberd/Delivery/ComponentConnection.pm \
	lib/DJabberd/Stanza/StreamFeatures.pm \
	blib/lib/DJabberd/Stanza/StreamFeatures.pm \
	lib/DJabberd/PresenceChecker/Local.pm \
	blib/lib/DJabberd/PresenceChecker/Local.pm \
	lib/DJabberd.pm \
	blib/lib/DJabberd.pm \
	lib/DJabberd/StreamVersion.pm \
	blib/lib/DJabberd/StreamVersion.pm \
	lib/DJabberd/DialbackParams.pm \
	blib/lib/DJabberd/DialbackParams.pm \
	lib/DJabberd/Queue/ServerOut.pm \
	blib/lib/DJabberd/Queue/ServerOut.pm \
	lib/DJabberd/Connection/ComponentOut.pm \
	blib/lib/DJabberd/Connection/ComponentOut.pm \
	lib/DJabberd/Util.pm \
	blib/lib/DJabberd/Util.pm \
	lib/DJabberd/Stanza/DialbackResult.pm \
	blib/lib/DJabberd/Stanza/DialbackResult.pm \
	lib/DJabberd/XMLParser.pm \
	blib/lib/DJabberd/XMLParser.pm \
	lib/DJabberd/ClusterMessage/DeliverStanza.pm \
	blib/lib/DJabberd/ClusterMessage/DeliverStanza.pm \
	lib/DJabberd/Agent.pm \
	blib/lib/DJabberd/Agent.pm \
	lib/DJabberd/Callback.pm \
	blib/lib/DJabberd/Callback.pm \
	lib/DJabberd/AWS/Authen.pm \
	blib/lib/DJabberd/AWS/Authen.pm \
	lib/DJabberd/RosterItem.pm \
	blib/lib/DJabberd/RosterItem.pm \
	lib/DJabberd/Connection/ComponentIn.pm \
	blib/lib/DJabberd/Connection/ComponentIn.pm \
	lib/DJabberd/ClusterMessage.pm \
	blib/lib/DJabberd/ClusterMessage.pm \
	lib/DJabberd/Connection/DialbackVerify.pm \
	blib/lib/DJabberd/Connection/DialbackVerify.pm \
	lib/DJabberd/Authen/StaticPassword.pm \
	blib/lib/DJabberd/Authen/StaticPassword.pm \
	lib/DJabberd/Bot.pm \
	blib/lib/DJabberd/Bot.pm \
	lib/DJabberd/Delivery/LocalVHosts.pm \
	blib/lib/DJabberd/Delivery/LocalVHosts.pm \
	lib/DJabberd/BotContext.pm \
	blib/lib/DJabberd/BotContext.pm \
	lib/DJabberd/AWS/S3.pm \
	blib/lib/DJabberd/AWS/S3.pm \
	lib/DJabberd/HookDocs.pm \
	blib/lib/DJabberd/HookDocs.pm \
	lib/DJabberd/Stanza/DialbackVerify.pm \
	blib/lib/DJabberd/Stanza/DialbackVerify.pm \
	lib/DJabberd/XMLElement.pm \
	blib/lib/DJabberd/XMLElement.pm \
	lib/DJabberd/SAXHandler.pm \
	blib/lib/DJabberd/SAXHandler.pm \
	lib/DJabberd/StreamStart.pm \
	blib/lib/DJabberd/StreamStart.pm \
	lib/DJabberd/Connection/ClientIn.pm \
	blib/lib/DJabberd/Connection/ClientIn.pm \
	lib/DJabberd/Delivery/S2S.pm \
	blib/lib/DJabberd/Delivery/S2S.pm \
	lib/DJabberd/Delivery.pm \
	blib/lib/DJabberd/Delivery.pm \
	lib/DJabberd/Roster.pm \
	blib/lib/DJabberd/Roster.pm \
	lib/DJabberd/IQ.pm \
	blib/lib/DJabberd/IQ.pm \
	lib/DJabberd/AWS/AsyncHTTP.pm \
	blib/lib/DJabberd/AWS/AsyncHTTP.pm \
	lib/DJabberd/Presence.pm \
	blib/lib/DJabberd/Presence.pm \
	lib/DJabberd/Subscription.pm \
	blib/lib/DJabberd/Subscription.pm \
	lib/DJabberd/Stanza.pm \
	blib/lib/DJabberd/Stanza.pm \
	lib/DJabberd/Connection/ServerIn.pm \
	blib/lib/DJabberd/Connection/ServerIn.pm \
	lib/DJabberd/Delivery/Local.pm \
	blib/lib/DJabberd/Delivery/Local.pm \
	lib/DJabberd/Message.pm \
	blib/lib/DJabberd/Message.pm \
	lib/DJabberd/Authen/AllowedUsers.pm \
	blib/lib/DJabberd/Authen/AllowedUsers.pm \
	lib/DJabberd/Component/Example.pm \
	blib/lib/DJabberd/Component/Example.pm \
	lib/DJabberd/Connection.pm \
	blib/lib/DJabberd/Connection.pm \
	lib/DJabberd/RosterStorage.pm \
	blib/lib/DJabberd/RosterStorage.pm \
	lib/DJabberd/Plugin.pm \
	blib/lib/DJabberd/Plugin.pm \
	lib/DJabberd/Authen.pm \
	blib/lib/DJabberd/Authen.pm \
	lib/DJabberd/Connection/SimpleIn.pm \
	blib/lib/DJabberd/Connection/SimpleIn.pm \
	lib/DJabberd/DNS.pm \
	blib/lib/DJabberd/DNS.pm \
	lib/DJabberd/VHost.pm \
	blib/lib/DJabberd/VHost.pm \
	lib/DJabberd/AWS/RosterStorage.pm \
	blib/lib/DJabberd/AWS/RosterStorage.pm \
	lib/DJabberd/AWS/Config.pm \
	blib/lib/DJabberd/AWS/Config.pm \
	lib/DJabberd/Component/External.pm \
	blib/lib/DJabberd/Component/External.pm \
	lib/DJabberd/TestSAXHandler.pm \
	blib/lib/DJabberd/TestSAXHandler.pm \
	lib/DJabberd/RosterStorage/InMemoryOnly.pm \
	blib/lib/DJabberd/RosterStorage/InMemoryOnly.pm \
	lib/DJabberd/PresenceChecker/Dummy.pm \
	blib/lib/DJabberd/PresenceChecker/Dummy.pm \
	ClientIn.pm \
	$(INST_LIB)/ClientIn.pm \
	lib/DJabberd/Queue.pm \
	blib/lib/DJabberd/Queue.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 1.50
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)'



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(SHELL) -c true
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) "-MExtUtils::Command" -e mkpath
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) "-MExtUtils::Command" -e eqtime
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install({@ARGV}, '\''$(VERBINST)'\'', 0, '\''$(UNINST)'\'');'
DOC_INSTALL = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e perllocal_install
UNINSTALL = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e uninstall
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e warn_if_old_packlist
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(PERLRUN) "-MExtUtils::MY" -e "MY->fixin(shift)"


# --- MakeMaker makemakerdflt section:
makemakerdflt: all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = DJabberd
DISTVNAME = DJabberd-0.83


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) 755 $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) 755 $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) 755 $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) 755 $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) 755 $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) 755 $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) 755 $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) 755 $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/DJabberd/Connection/ComponentOut.pm \
	lib/DJabberd/Component.pm \
	lib/DJabberd/Connection/ComponentIn.pm \
	lib/DJabberd/Delivery/ComponentConnection.pm \
	lib/DJabberd/Component/Example.pm \
	lib/DJabberd/Component/External.pm \
	lib/DJabberd.pm \
	lib/DJabberd/Delivery/LocalVHosts.pm \
	lib/DJabberd/Connection/ComponentOut.pm \
	lib/DJabberd/Component.pm \
	lib/DJabberd/Connection/ComponentIn.pm \
	lib/DJabberd/Delivery/ComponentConnection.pm \
	lib/DJabberd/Component/Example.pm \
	lib/DJabberd/Component/External.pm \
	lib/DJabberd.pm \
	lib/DJabberd/Delivery/LocalVHosts.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/DJabberd/Connection/ComponentOut.pm $(INST_MAN3DIR)/DJabberd::Connection::ComponentOut.$(MAN3EXT) \
	  lib/DJabberd/Component.pm $(INST_MAN3DIR)/DJabberd::Component.$(MAN3EXT) \
	  lib/DJabberd/Connection/ComponentIn.pm $(INST_MAN3DIR)/DJabberd::Connection::ComponentIn.$(MAN3EXT) \
	  lib/DJabberd/Delivery/ComponentConnection.pm $(INST_MAN3DIR)/DJabberd::Delivery::ComponentConnection.$(MAN3EXT) \
	  lib/DJabberd/Component/Example.pm $(INST_MAN3DIR)/DJabberd::Component::Example.$(MAN3EXT) \
	  lib/DJabberd/Component/External.pm $(INST_MAN3DIR)/DJabberd::Component::External.$(MAN3EXT) \
	  lib/DJabberd.pm $(INST_MAN3DIR)/DJabberd.$(MAN3EXT) \
	  lib/DJabberd/Delivery/LocalVHosts.pm $(INST_MAN3DIR)/DJabberd::Delivery::LocalVHosts.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = djabberd

pure_all :: $(INST_SCRIPT)/djabberd
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/djabberd 

$(INST_SCRIPT)/djabberd : djabberd $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/djabberd
	$(CP) djabberd $(INST_SCRIPT)/djabberd
	$(FIXIN) $(INST_SCRIPT)/djabberd
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/djabberd



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  *$(LIB_EXT) core \
	  core.[0-9] $(INST_ARCHAUTODIR)/extralibs.all \
	  core.[0-9][0-9] $(BASEEXT).bso \
	  pm_to_blib.ts core.[0-9][0-9][0-9][0-9] \
	  $(BASEEXT).x $(BOOTSTRAP) \
	  perl$(EXE_EXT) tmon.out \
	  *$(OBJ_EXT) pm_to_blib \
	  $(INST_ARCHAUTODIR)/extralibs.ld blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9][0-9] *perl.core \
	  core.*perl.*.? $(MAKE_APERL_FILE) \
	  perl $(BASEEXT).def \
	  core.[0-9][0-9][0-9] mon.out \
	  lib$(BASEEXT).def perlmain.c \
	  perl.exe so_locations \
	  $(BASEEXT).exp 
	- $(RM_RF) \
	  blib 
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile : create_distdir
	$(NOECHO) $(ECHO) Generating META.yml
	$(NOECHO) $(ECHO) '# http://module-build.sourceforge.net/META-spec.html' > META_new.yml
	$(NOECHO) $(ECHO) '#XXXXXXX This is a prototype!!!  It will change in the future!!! XXXXX#' >> META_new.yml
	$(NOECHO) $(ECHO) 'name:         DJabberd' >> META_new.yml
	$(NOECHO) $(ECHO) 'version:      0.83' >> META_new.yml
	$(NOECHO) $(ECHO) 'version_from: lib/DJabberd.pm' >> META_new.yml
	$(NOECHO) $(ECHO) 'installdirs:  site' >> META_new.yml
	$(NOECHO) $(ECHO) 'requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '    Danga::Socket:                 1.51' >> META_new.yml
	$(NOECHO) $(ECHO) '    Digest::HMAC_SHA1:             0' >> META_new.yml
	$(NOECHO) $(ECHO) '    Log::Log4perl:                 0' >> META_new.yml
	$(NOECHO) $(ECHO) '    Net::DNS:                      0.48' >> META_new.yml
	$(NOECHO) $(ECHO) '    Net::SSLeay:                   0' >> META_new.yml
	$(NOECHO) $(ECHO) '    XML::LibXML::SAX:              0' >> META_new.yml
	$(NOECHO) $(ECHO) '    XML::SAX:                      0' >> META_new.yml
	$(NOECHO) $(ECHO) '' >> META_new.yml
	$(NOECHO) $(ECHO) 'distribution_type: module' >> META_new.yml
	$(NOECHO) $(ECHO) 'generated_by: ExtUtils::MakeMaker version 6.30' >> META_new.yml
	-$(NOECHO) $(MV) META_new.yml $(DISTVNAME)/META.yml


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ *.orig */*~ */*.orig



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';'

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir distmeta 
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{META.yml} => q{Module meta-data (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add META.yml to MANIFEST: $${'\''@'\''}\n"'



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $${'\''@'\''}\n"'
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: all pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: all pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: all pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: all pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE)

test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0,83,0,0">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <TITLE>$(DISTNAME)</TITLE>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>scalable, extensible Jabber/XMPP server.</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Brad Fitzpatrick &lt;brad@danga.com&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Danga-Socket" VERSION="1,51,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Digest-HMAC_SHA1" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Log-Log4perl" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Net-DNS" VERSION="0,48,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Net-SSLeay" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="XML-LibXML-SAX" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="XML-SAX" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <OS NAME="$(OSNAME)" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="darwin-thread-multi-2level" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', '\''$(PM_FILTER)'\'')' \
	  lib/DJabberd/Component.pm blib/lib/DJabberd/Component.pm \
	  lib/DJabberd/JID.pm blib/lib/DJabberd/JID.pm \
	  lib/DJabberd/Connection/ClusterOut.pm blib/lib/DJabberd/Connection/ClusterOut.pm \
	  lib/DJabberd/Connection/ServerOut.pm blib/lib/DJabberd/Connection/ServerOut.pm \
	  lib/DJabberd/Component/Node.pm blib/lib/DJabberd/Component/Node.pm \
	  lib/DJabberd/Agent/Node.pm blib/lib/DJabberd/Agent/Node.pm \
	  lib/DJabberd/Stanza/StartTLS.pm blib/lib/DJabberd/Stanza/StartTLS.pm \
	  lib/DJabberd/Connection/ClusterIn.pm blib/lib/DJabberd/Connection/ClusterIn.pm \
	  lib/DJabberd/Connection/Admin.pm blib/lib/DJabberd/Connection/Admin.pm \
	  lib/DJabberd/Queue/ClusterOut.pm blib/lib/DJabberd/Queue/ClusterOut.pm \
	  lib/DJabberd/Cluster.pm blib/lib/DJabberd/Cluster.pm \
	  lib/DJabberd/Stats.pm blib/lib/DJabberd/Stats.pm \
	  lib/DJabberd/PresenceChecker.pm blib/lib/DJabberd/PresenceChecker.pm \
	  lib/DJabberd/Bot/Admin.pm blib/lib/DJabberd/Bot/Admin.pm \
	  lib/DJabberd/Log.pm blib/lib/DJabberd/Log.pm \
	  lib/DJabberd/Authen/InMemoryOnly.pm blib/lib/DJabberd/Authen/InMemoryOnly.pm \
	  lib/DJabberd/Connection/OldSSLClientIn.pm blib/lib/DJabberd/Connection/OldSSLClientIn.pm \
	  lib/DJabberd/Delivery/ComponentConnection.pm blib/lib/DJabberd/Delivery/ComponentConnection.pm \
	  lib/DJabberd/Stanza/StreamFeatures.pm blib/lib/DJabberd/Stanza/StreamFeatures.pm \
	  lib/DJabberd/PresenceChecker/Local.pm blib/lib/DJabberd/PresenceChecker/Local.pm \
	  lib/DJabberd.pm blib/lib/DJabberd.pm \
	  lib/DJabberd/StreamVersion.pm blib/lib/DJabberd/StreamVersion.pm \
	  lib/DJabberd/DialbackParams.pm blib/lib/DJabberd/DialbackParams.pm \
	  lib/DJabberd/Queue/ServerOut.pm blib/lib/DJabberd/Queue/ServerOut.pm \
	  lib/DJabberd/Connection/ComponentOut.pm blib/lib/DJabberd/Connection/ComponentOut.pm \
	  lib/DJabberd/Util.pm blib/lib/DJabberd/Util.pm \
	  lib/DJabberd/Stanza/DialbackResult.pm blib/lib/DJabberd/Stanza/DialbackResult.pm \
	  lib/DJabberd/XMLParser.pm blib/lib/DJabberd/XMLParser.pm \
	  lib/DJabberd/ClusterMessage/DeliverStanza.pm blib/lib/DJabberd/ClusterMessage/DeliverStanza.pm \
	  lib/DJabberd/Agent.pm blib/lib/DJabberd/Agent.pm \
	  lib/DJabberd/Callback.pm blib/lib/DJabberd/Callback.pm \
	  lib/DJabberd/AWS/Authen.pm blib/lib/DJabberd/AWS/Authen.pm \
	  lib/DJabberd/RosterItem.pm blib/lib/DJabberd/RosterItem.pm \
	  lib/DJabberd/Connection/ComponentIn.pm blib/lib/DJabberd/Connection/ComponentIn.pm \
	  lib/DJabberd/ClusterMessage.pm blib/lib/DJabberd/ClusterMessage.pm \
	  lib/DJabberd/Connection/DialbackVerify.pm blib/lib/DJabberd/Connection/DialbackVerify.pm \
	  lib/DJabberd/Authen/StaticPassword.pm blib/lib/DJabberd/Authen/StaticPassword.pm \
	  lib/DJabberd/Bot.pm blib/lib/DJabberd/Bot.pm \
	  lib/DJabberd/Delivery/LocalVHosts.pm blib/lib/DJabberd/Delivery/LocalVHosts.pm \
	  lib/DJabberd/BotContext.pm blib/lib/DJabberd/BotContext.pm \
	  lib/DJabberd/AWS/S3.pm blib/lib/DJabberd/AWS/S3.pm \
	  lib/DJabberd/HookDocs.pm blib/lib/DJabberd/HookDocs.pm \
	  lib/DJabberd/Stanza/DialbackVerify.pm blib/lib/DJabberd/Stanza/DialbackVerify.pm \
	  lib/DJabberd/XMLElement.pm blib/lib/DJabberd/XMLElement.pm \
	  lib/DJabberd/SAXHandler.pm blib/lib/DJabberd/SAXHandler.pm \
	  lib/DJabberd/StreamStart.pm blib/lib/DJabberd/StreamStart.pm \
	  lib/DJabberd/Connection/ClientIn.pm blib/lib/DJabberd/Connection/ClientIn.pm \
	  lib/DJabberd/Delivery/S2S.pm blib/lib/DJabberd/Delivery/S2S.pm \
	  lib/DJabberd/Delivery.pm blib/lib/DJabberd/Delivery.pm \
	  lib/DJabberd/Roster.pm blib/lib/DJabberd/Roster.pm \
	  lib/DJabberd/IQ.pm blib/lib/DJabberd/IQ.pm \
	  lib/DJabberd/AWS/AsyncHTTP.pm blib/lib/DJabberd/AWS/AsyncHTTP.pm \
	  lib/DJabberd/Presence.pm blib/lib/DJabberd/Presence.pm \
	  lib/DJabberd/Subscription.pm blib/lib/DJabberd/Subscription.pm \
	  lib/DJabberd/Stanza.pm blib/lib/DJabberd/Stanza.pm \
	  lib/DJabberd/Connection/ServerIn.pm blib/lib/DJabberd/Connection/ServerIn.pm \
	  lib/DJabberd/Delivery/Local.pm blib/lib/DJabberd/Delivery/Local.pm \
	  lib/DJabberd/Message.pm blib/lib/DJabberd/Message.pm \
	  lib/DJabberd/Authen/AllowedUsers.pm blib/lib/DJabberd/Authen/AllowedUsers.pm \
	  lib/DJabberd/Component/Example.pm blib/lib/DJabberd/Component/Example.pm \
	  lib/DJabberd/Connection.pm blib/lib/DJabberd/Connection.pm \
	  lib/DJabberd/RosterStorage.pm blib/lib/DJabberd/RosterStorage.pm \
	  lib/DJabberd/Plugin.pm blib/lib/DJabberd/Plugin.pm \
	  lib/DJabberd/Authen.pm blib/lib/DJabberd/Authen.pm \
	  lib/DJabberd/Connection/SimpleIn.pm blib/lib/DJabberd/Connection/SimpleIn.pm \
	  lib/DJabberd/DNS.pm blib/lib/DJabberd/DNS.pm \
	  lib/DJabberd/VHost.pm blib/lib/DJabberd/VHost.pm \
	  lib/DJabberd/AWS/RosterStorage.pm blib/lib/DJabberd/AWS/RosterStorage.pm \
	  lib/DJabberd/AWS/Config.pm blib/lib/DJabberd/AWS/Config.pm \
	  lib/DJabberd/Component/External.pm blib/lib/DJabberd/Component/External.pm \
	  lib/DJabberd/TestSAXHandler.pm blib/lib/DJabberd/TestSAXHandler.pm \
	  lib/DJabberd/RosterStorage/InMemoryOnly.pm blib/lib/DJabberd/RosterStorage/InMemoryOnly.pm \
	  lib/DJabberd/PresenceChecker/Dummy.pm blib/lib/DJabberd/PresenceChecker/Dummy.pm \
	  ClientIn.pm $(INST_LIB)/ClientIn.pm \
	  lib/DJabberd/Queue.pm blib/lib/DJabberd/Queue.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
