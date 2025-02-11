from typing import Set

#####################################
########## Django settings ##########
#####################################
# See <https://docs.djangoproject.com/en/1.11/ref/settings/>
# for more info and help. If you are stuck, you can try Googling about
# Django - many of these settings below have external documentation about them.
#
# The settings listed here are of special interest in configuring the site.

# SECURITY WARNING: keep the secret key used in production secret!
# You may use <http://www.miniwebtool.com/django-secret-key-generator/>
# to generate this key.
SECRET_KEY = os.environ.get('SECRET_KEY', '')
# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.environ.get('DEBUG', '0') == '1'
HOST = os.environ.get('HOST', 'mcpt.ca')

# You must do this once you set DEBUG to False.
ALLOWED_HOSTS = [HOST]
CSRF_TRUSTED_ORIGINS = ["https://" + HOST]

# Optional apps that DMOJ can make use of.
INSTALLED_APPS += ("discord_integration",)

# Caching. You can use memcached or redis instead.
# Documentation: <https://docs.djangoproject.com/en/1.11/topics/cache/>
CACHES = {
	'default': {
		'BACKEND': 'django_redis.cache.RedisCache',
		'LOCATION': 'redis://redis:6379/1',
	}
}

# Your database credentials. Only MySQL is supported by DMOJ.
# Documentation: <https://docs.djangoproject.com/en/1.11/ref/databases/>
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.mysql',
		'NAME': os.environ.get('MYSQL_DATABASE', ''),
		'USER': os.environ.get('MYSQL_USER', ''),
		'PASSWORD': os.environ.get('MYSQL_PASSWORD', ''),
		'HOST': os.environ.get('MYSQL_HOST', 'db'),
		'OPTIONS': {
			'charset': 'utf8mb4',
			'sql_mode': 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION',
		},
	}
}

# Sessions.
# Documentation: <https://docs.djangoproject.com/en/1.11/topics/http/sessions/>
# SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'

# Internationalization.
# Documentation: <https://docs.djangoproject.com/en/1.11/topics/i18n/>
LANGUAGE_CODE = 'en-ca'
DEFAULT_USER_TIME_ZONE = 'America/Toronto'
USE_I18N = True
USE_L10N = True
USE_TZ = True

PASSWORD_HASHERS = [
	'django.contrib.auth.hashers.Argon2PasswordHasher',
	'django.contrib.auth.hashers.PBKDF2PasswordHasher',
	'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
	'django.contrib.auth.hashers.BCryptSHA256PasswordHasher',
]

# To use Mailgun, uncomment this block.
# You will need to run `pip install django-mailgun` for to get `MailgunBackend`.
# EMAIL_BACKEND = 'django_mailgun.MailgunBackend'
# MAILGUN_ACCESS_KEY = '<your Mailgun access key>'
# MAILGUN_SERVER_NAME = '<your Mailgun domain>'

# You can also use Sendgrid, with `pip install sendgrid-django`.
# EMAIL_BACKEND = 'sgbackend.SendGridBackend'
# SENDGRID_API_KEY = '<Your SendGrid API Key>'

# The DMOJ site is able to notify administrators of errors via email,
# if configured as shown below.

DEFAULT_FROM_EMAIL = 'judge@mcpt.ca'
SERVER_EMAIL = 'judge@mcpt.ca'

ADMINS = [("Jason Cameron", "mcpt@jasoncameron.dev")]

##################################################
########### Static files configuration. ##########
##################################################
# See <https://docs.djangoproject.com/en/1.11/howto/static-files/>.

# Change this to somewhere more permanent., especially if you are using a
# webserver to serve the static files. This is the directory where all the
# static files DMOJ uses will be collected to.
# You must configure your webserver to serve this directory as /static/ in production.
STATIC_ROOT = '/assets/static/'

# URL to access static files.
STATIC_URL = '/static/'

# Uncomment to use hashed filenames with the cache framework.
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'



## django-compressor settings, for speeding up page load times by minifying CSS and JavaScript files.
# Documentation: https://django-compressor.readthedocs.io/en/latest/
COMPRESS_ENABLED = False
# COMPRESS_ROOT = 'cache
# COMPRESS_OUTPUT_DIR = 'cache'

COMPRESS_CSS_FILTERS = [
	'compressor.filters.css_default.CssAbsoluteFilter',
	'compressor.filters.cssmin.CSSMinFilter',
]
COMPRESS_JS_FILTERS = ['compressor.filters.jsmin.JSMinFilter']
COMPRESS_STORAGE = 'compressor.storage.GzipCompressorFileStorage'
STATICFILES_FINDERS += ('compressor.finders.CompressorFinder',)

############################################
########## DMOJ-specific settings ##########
############################################

## DMOJ site display settings.
SITE_NAME = 'MCPT'
SITE_LONG_NAME = 'MCPT: Mackenzie Competitive Programming Team'
SITE_ADMIN_EMAIL = SERVER_EMAIL
TERMS_OF_SERVICE_URL = '//mcpt.ca/tos'  # Use a flatpage.

## Bridge controls.
# The judge connection address and port; where the judges will connect to the site.
# You should change this to something your judges can actually connect to
# (e.g., a port that is unused and unblocked by a firewall).
BRIDGED_JUDGE_ADDRESS = [('0.0.0.0', 9999)]
# The bridged daemon bind address and port to communicate with the site.
BRIDGED_DJANGO_ADDRESS = [('0.0.0.0', 9998)]
BRIDGED_DJANGO_CONNECT = ('bridged', 9998)

## DMOJ features.
# Set to True to enable full-text searching for problems.
ENABLE_FTS = True

# Set of email providers to ban when a user registers, e.g., {'throwawaymail.com'}.
BAD_MAIL_PROVIDERS: Set[str] = set()

## Event server.
# Uncomment to enable live updating.
EVENT_DAEMON_USE = True

# Uncomment this section to use websocket/daemon.js included in the site.
# EVENT_DAEMON_POST = '<ws:// URL to post to>'

# If you are using the defaults from the guide, it is this:
EVENT_DAEMON_POST = 'ws://wsevent:15101/'

# These are the publicly accessed interface configurations.
# They should match those used by the script.
EVENT_DAEMON_GET = 'ws://{host}/event/'.format(host=HOST)
EVENT_DAEMON_GET_SSL = 'wss://{host}/event/'.format(host=HOST)
EVENT_DAEMON_POLL = '/channels/'

# If you would like to use the AMQP-based event server from <https://github.com/DMOJ/event-server>,
# uncomment this section instead. This is more involved, and recommended to be done
# only after you have a working event server.
# EVENT_DAEMON_AMQP = '<amqp:// URL to connect to, including username and password>'
# EVENT_DAEMON_AMQP_EXCHANGE = '<AMQP exchange to use>'

## CDN control.
# Base URL for a copy of ace editor.
# Should contain ace.js, along with mode-*.js.
ACE_URL = '//cdnjs.cloudflare.com/ajax/libs/ace/1.2.3/'
JQUERY_JS = '//cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.min.js'
SELECT2_JS_URL = '//cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js'
SELECT2_CSS_URL = '//cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css'

# A map of Earth in Equirectangular projection, for timezone selection.
# Please try not to hotlink this poor site.
TIMEZONE_MAP = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Blue_Marble_2002.png/1024px-Blue_Marble_2002.png'

## Camo (https://github.com/atmos/camo) usage.
# DMOJ_CAMO_URL = "<URL to your camo install>"
# DMOJ_CAMO_KEY = "<The CAMO_KEY environmental variable you used>"

# Domains to exclude from being camo'd.
# DMOJ_CAMO_EXCLUDE = ("https://dmoj.ml", "https://dmoj.ca")

# Set to True to use https when dealing with protocol-relative URLs.
# See <http://www.paulirish.com/2010/the-protocol-relative-url/> for what they are.
# DMOJ_CAMO_HTTPS = False

# HTTPS level. Affects <link rel='canonical'> elements generated.
# Set to 0 to make http URLs canonical.
# Set to 1 to make the currently used protocol canonical.
# Set to 2 to make https URLs canonical.
# DMOJ_HTTPS = 0

## PDF rendering settings.
# Directory to cache the PDF.
DMOJ_PDF_PROBLEM_CACHE = '/pdfcache/'

# Path to use for nginx's X-Accel-Redirect feature.
# Should be an internal location mapped to the above directory.
DMOJ_PDF_PROBLEM_INTERNAL = '/pdfcache'

# Enable Selenium PDF generation
USE_SELENIUM = True

DMOJ_USER_DATA_DOWNLOAD = True
DMOJ_USER_DATA_CACHE = '/datacache'
DMOJ_USER_DATA_INTERNAL = '/datacache'

#############
## Mathoid ##
#############
# Documentation: https://github.com/wikimedia/mathoid
MATHOID_URL = 'http://mathoid:10044'
MATHOID_CACHE_ROOT = '/mathoid/'
MATHOID_CACHE_URL = '//{host}/mathoid/'.format(host=HOST)

############
## Pdfoid ##
############

DMOJ_PDF_PDFOID_URL = 'http://pdfoid:8888'

############
## Texoid ##
############

TEXOID_URL = 'http://texoid:8888'
TEXOID_CACHE_ROOT = '/texoid/'
TEXOID_CACHE_URL = '//{host}/texoid/'.format(host=HOST)

## ======== Logging Settings ========
# Documentation: https://docs.djangoproject.com/en/1.9/ref/settings/#logging
#                https://docs.python.org/2/library/logging.config.html#logging-config-dictschema
LOGGING = {
	'version': 1,
	'disable_existing_loggers': False,
	'filters': {
		'silence_invalid_header': {
			'()': 'judge.filters.SilenceInvalidHttpHostHeader'
		}, },
	'formatters': {
		'file': {
			'format': '%(levelname)s %(asctime)s %(module)s %(message)s',
		},
		'simple': {
			'format': '%(levelname)s %(message)s',
		},
	},
	'handlers': {
		'bridge': {
			'level': 'INFO',
			'class': 'logging.handlers.RotatingFileHandler',
			'filename': '/logs/bridge.log',
			'maxBytes': 10 * 1024 * 1024,
			'backupCount': 10,
			'formatter': 'file',
			'filters': ['silence_invalid_header'],
		},
		'all': {
			'level': 'INFO',
			'class': 'logging.handlers.RotatingFileHandler',
			'filename': '/logs/all.log',
			'maxBytes': 10 * 1024 * 1024,
			'backupCount': 10,
			'formatter': 'file',
			'filters': ['silence_invalid_header'],
		},
		'mail_admins': {
			'level': 'ERROR',
			'class': 'dmoj.throttle_mail.ThrottledEmailHandler',
			'filters': ['silence_invalid_header'],
		},
		'console': {
			'level': 'DEBUG',
			'class': 'logging.StreamHandler',
			'formatter': 'file',
			'filters': ['silence_invalid_header'],
		},
		'discord_integration': {
			'level': 'ERROR',
			'class': 'discord_integration.log.DiscordMessageHandler',
			'filters': ['silence_invalid_header'],
		},
		'discord_simple': {
			'level': 'INFO',
			'class': 'discord_integration.log.SimpleDiscordMessageHandler',
			'filters': ['silence_invalid_header'],
		},
	},
	'loggers': {
		# Site 500 error mails.
		'django.request': {
			'handlers': ['discord_integration'],
			'level': 'ERROR',
			'propagate': True,
		},
		# Site tickets
		'judge.ticket': {
			'handlers': ['discord_simple'],
			'level': 'INFO',
			'propagate': False,
		},
		# Judging logs as received by bridged.
		'judge.bridge': {
			'handlers': ['bridge', 'discord_integration'],
			'propagate': True,
		},
		# Catch all log to stderr.
		'': {
			'handlers': ['console', 'all'],
		},
	},
}

## ======== Integration Settings ========
## Python Social Auth
# Documentation: https://python-social-auth.readthedocs.io/en/latest/
# You can define these to enable authentication through the following services.
# SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = ''
# SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = ''
# SOCIAL_AUTH_FACEBOOK_KEY = ''
# SOCIAL_AUTH_FACEBOOK_SECRET = ''
# SOCIAL_AUTH_GITHUB_SECURE_KEY = ''
# SOCIAL_AUTH_GITHUB_SECURE_SECRET = ''
# SOCIAL_AUTH_DROPBOX_OAUTH2_KEY = ''
# SOCIAL_AUTH_DROPBOX_OAUTH2_SECRET = ''


#########################################
########## Email configuration ##########
#########################################
# See <https://docs.djangoproject.com/en/1.11/topics/email/#email-backends>
# for more documentation. You should follow the information there to define
# your email settings.

# Use this if you are just testing.
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

EMAIL_USE_TLS = True
EMAIL_HOST = os.environ.get('EMAIL_HOST', None)
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', None)
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', None)
EMAIL_PORT = os.environ.get('EMAIL_PORT', 587)

## ======== Custom Configuration ========
# You may add whatever django configuration you would like here.
# Do try to keep it separate so you can quickly patch in new settings.

# Uncomment if you're using HTTPS to ensure CSRF and session cookies are
# sent only with an HTTPS connection.
# CSRF_COOKIE_SECURE = True
# SESSION_COOKIE_SECURE = True

MOSS_API_KEY = os.environ.get('MOSS_API_KEY', None)

REGISTRATION_OPEN = True # Allow users to register
DMOJ_RATING_COLORS = True
X_FRAME_OPTIONS = 'DENY'

CELERY_BROKER_URL = 'redis://redis:6379/0'
CELERY_RESULT_BACKEND = 'redis://redis:6379/0'

DMOJ_PROBLEM_DATA_ROOT = '/problems/'

DMOJ_RESOURCES = '/assets/resources/'

MEDIA_ROOT = '/media/'
MEDIA_URL = '/media/'

DMOJ_ICS_REPORT_PERIODS = {
	1: {"name": "Mr. Guglielmi", "email": "Guglielmi@jasoncameron.dev"},
	2: {"name": "Mrs. Krasteva", "email": "Krasteva@jasoncameron.dev"},
}

WPADMIN['admin']['title'] = 'WLMOJ Admin'

if DEBUG:
	EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
