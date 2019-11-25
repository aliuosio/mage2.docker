-- SMTP Settings for Mailhog
INSERT INTO core_config_data SET path='system/gmailsmtpapp/smtphost', VALUE='mailhog';
INSERT INTO core_config_data SET path='system/gmailsmtpapp/ssl', VALUE='none';
INSERT INTO core_config_data SET path='system/gmailsmtpapp/auth', VALUE='NONE';
INSERT INTO core_config_data SET path='system/gmailsmtpapp/smtpport', VALUE='1025';