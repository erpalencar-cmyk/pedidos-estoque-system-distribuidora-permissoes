-- DROP SCHEMA auth;

CREATE SCHEMA auth AUTHORIZATION supabase_admin;

-- DROP TYPE auth."aal_level";

CREATE TYPE auth."aal_level" AS ENUM (
	'aal1',
	'aal2',
	'aal3');

-- DROP TYPE auth."code_challenge_method";

CREATE TYPE auth."code_challenge_method" AS ENUM (
	's256',
	'plain');

-- DROP TYPE auth."factor_status";

CREATE TYPE auth."factor_status" AS ENUM (
	'unverified',
	'verified');

-- DROP TYPE auth."factor_type";

CREATE TYPE auth."factor_type" AS ENUM (
	'totp',
	'webauthn',
	'phone');

-- DROP TYPE auth."oauth_authorization_status";

CREATE TYPE auth."oauth_authorization_status" AS ENUM (
	'pending',
	'approved',
	'denied',
	'expired');

-- DROP TYPE auth."oauth_client_type";

CREATE TYPE auth."oauth_client_type" AS ENUM (
	'public',
	'confidential');

-- DROP TYPE auth."oauth_registration_type";

CREATE TYPE auth."oauth_registration_type" AS ENUM (
	'dynamic',
	'manual');

-- DROP TYPE auth."oauth_response_type";

CREATE TYPE auth."oauth_response_type" AS ENUM (
	'code');

-- DROP TYPE auth."one_time_token_type";

CREATE TYPE auth."one_time_token_type" AS ENUM (
	'confirmation_token',
	'reauthentication_token',
	'recovery_token',
	'email_change_token_new',
	'email_change_token_current',
	'phone_change_token');

-- DROP SEQUENCE auth.refresh_tokens_id_seq;

CREATE SEQUENCE auth.refresh_tokens_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO supabase_auth_admin;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;
-- auth.audit_log_entries definição

-- Drop table

-- DROP TABLE auth.audit_log_entries;

CREATE TABLE auth.audit_log_entries ( instance_id uuid NULL, id uuid NOT NULL, payload json NULL, created_at timestamptz NULL, ip_address varchar(64) DEFAULT ''::character varying NOT NULL, CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id));
CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);
COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';

-- Permissions

ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.audit_log_entries TO supabase_auth_admin;
GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT ALL ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO anon;
GRANT SELECT ON TABLE auth.audit_log_entries TO authenticated;
GRANT SELECT ON TABLE auth.audit_log_entries TO service_role;


-- auth.flow_state definição

-- Drop table

-- DROP TABLE auth.flow_state;

CREATE TABLE auth.flow_state ( id uuid NOT NULL, user_id uuid NULL, auth_code text NULL, "code_challenge_method" auth."code_challenge_method" NULL, code_challenge text NULL, provider_type text NOT NULL, provider_access_token text NULL, provider_refresh_token text NULL, created_at timestamptz NULL, updated_at timestamptz NULL, authentication_method text NOT NULL, auth_code_issued_at timestamptz NULL, invite_token text NULL, referrer text NULL, oauth_client_state_id uuid NULL, linking_target_id uuid NULL, email_optional bool DEFAULT false NOT NULL, CONSTRAINT flow_state_pkey PRIMARY KEY (id));
CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);
CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);
CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);
COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';

-- Permissions

ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.flow_state TO postgres;
GRANT ALL ON TABLE auth.flow_state TO supabase_auth_admin;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;
GRANT SELECT ON TABLE auth.flow_state TO anon;
GRANT SELECT ON TABLE auth.flow_state TO authenticated;
GRANT SELECT ON TABLE auth.flow_state TO service_role;


-- auth.instances definição

-- Drop table

-- DROP TABLE auth.instances;

CREATE TABLE auth.instances ( id uuid NOT NULL, "uuid" uuid NULL, raw_base_config text NULL, created_at timestamptz NULL, updated_at timestamptz NULL, CONSTRAINT instances_pkey PRIMARY KEY (id));
COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';

-- Permissions

ALTER TABLE auth.instances OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.instances TO supabase_auth_admin;
GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT ALL ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO anon;
GRANT SELECT ON TABLE auth.instances TO authenticated;
GRANT SELECT ON TABLE auth.instances TO service_role;


-- auth.oauth_client_states definição

-- Drop table

-- DROP TABLE auth.oauth_client_states;

CREATE TABLE auth.oauth_client_states ( id uuid NOT NULL, provider_type text NOT NULL, code_verifier text NULL, created_at timestamptz NOT NULL, CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id));
CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);
COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';

-- Permissions

ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


-- auth.oauth_clients definição

-- Drop table

-- DROP TABLE auth.oauth_clients;

CREATE TABLE auth.oauth_clients ( id uuid NOT NULL, client_secret_hash text NULL, registration_type auth."oauth_registration_type" NOT NULL, redirect_uris text NOT NULL, grant_types text NOT NULL, client_name text NULL, client_uri text NULL, logo_uri text NULL, created_at timestamptz DEFAULT now() NOT NULL, updated_at timestamptz DEFAULT now() NOT NULL, deleted_at timestamptz NULL, client_type auth."oauth_client_type" DEFAULT 'confidential'::auth.oauth_client_type NOT NULL, token_endpoint_auth_method text NOT NULL, CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)), CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)), CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)), CONSTRAINT oauth_clients_pkey PRIMARY KEY (id), CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text]))));
CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);

-- Permissions

ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


-- auth.schema_migrations definição

-- Drop table

-- DROP TABLE auth.schema_migrations;

CREATE TABLE auth.schema_migrations ( "version" varchar(255) NOT NULL, CONSTRAINT schema_migrations_pkey PRIMARY KEY (version));
COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';

-- Permissions

ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.schema_migrations TO supabase_auth_admin;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;
GRANT SELECT ON TABLE auth.schema_migrations TO anon;
GRANT SELECT ON TABLE auth.schema_migrations TO authenticated;
GRANT SELECT ON TABLE auth.schema_migrations TO service_role;


-- auth.sso_providers definição

-- Drop table

-- DROP TABLE auth.sso_providers;

CREATE TABLE auth.sso_providers ( id uuid NOT NULL, resource_id text NULL, created_at timestamptz NULL, updated_at timestamptz NULL, disabled bool NULL, CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0))), CONSTRAINT sso_providers_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));
CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);
COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';

-- Column comments

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';

-- Permissions

ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sso_providers TO postgres;
GRANT ALL ON TABLE auth.sso_providers TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;
GRANT SELECT ON TABLE auth.sso_providers TO anon;
GRANT SELECT ON TABLE auth.sso_providers TO authenticated;
GRANT SELECT ON TABLE auth.sso_providers TO service_role;


-- auth.users definição

-- Drop table

-- DROP TABLE auth.users;

CREATE TABLE auth.users ( instance_id uuid NULL, id uuid NOT NULL, aud varchar(255) NULL, "role" varchar(255) NULL, email varchar(255) NULL, encrypted_password varchar(255) NULL, email_confirmed_at timestamptz NULL, invited_at timestamptz NULL, confirmation_token varchar(255) NULL, confirmation_sent_at timestamptz NULL, recovery_token varchar(255) NULL, recovery_sent_at timestamptz NULL, email_change_token_new varchar(255) NULL, email_change varchar(255) NULL, email_change_sent_at timestamptz NULL, last_sign_in_at timestamptz NULL, raw_app_meta_data jsonb NULL, raw_user_meta_data jsonb NULL, is_super_admin bool NULL, created_at timestamptz NULL, updated_at timestamptz NULL, phone text DEFAULT NULL::character varying NULL, phone_confirmed_at timestamptz NULL, phone_change text DEFAULT ''::character varying NULL, phone_change_token varchar(255) DEFAULT ''::character varying NULL, phone_change_sent_at timestamptz NULL, confirmed_at timestamptz GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED NULL, email_change_token_current varchar(255) DEFAULT ''::character varying NULL, email_change_confirm_status int2 DEFAULT 0 NULL, banned_until timestamptz NULL, reauthentication_token varchar(255) DEFAULT ''::character varying NULL, reauthentication_sent_at timestamptz NULL, is_sso_user bool DEFAULT false NOT NULL, deleted_at timestamptz NULL, is_anonymous bool DEFAULT false NOT NULL, CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2))), CONSTRAINT users_phone_key UNIQUE (phone), CONSTRAINT users_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);
CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);
CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);
CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);
CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);
CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);
COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';
CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));
CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);
CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);
COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';

-- Column comments

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';

-- Permissions

ALTER TABLE auth.users OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.users TO supabase_auth_admin;
GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT ALL ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO anon;
GRANT SELECT ON TABLE auth.users TO authenticated;
GRANT SELECT ON TABLE auth.users TO service_role;


-- auth.identities definição

-- Drop table

-- DROP TABLE auth.identities;

CREATE TABLE auth.identities ( provider_id text NOT NULL, user_id uuid NOT NULL, identity_data jsonb NOT NULL, provider text NOT NULL, last_sign_in_at timestamptz NULL, created_at timestamptz NULL, updated_at timestamptz NULL, email text GENERATED ALWAYS AS (lower(identity_data ->> 'email'::text)) STORED NULL, id uuid DEFAULT gen_random_uuid() NOT NULL, CONSTRAINT identities_pkey PRIMARY KEY (id), CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider), CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);
COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';
CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);
COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';

-- Column comments

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';

-- Permissions

ALTER TABLE auth.identities OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.identities TO postgres;
GRANT ALL ON TABLE auth.identities TO supabase_auth_admin;
GRANT ALL ON TABLE auth.identities TO dashboard_user;
GRANT SELECT ON TABLE auth.identities TO anon;
GRANT SELECT ON TABLE auth.identities TO authenticated;
GRANT SELECT ON TABLE auth.identities TO service_role;


-- auth.mfa_factors definição

-- Drop table

-- DROP TABLE auth.mfa_factors;

CREATE TABLE auth.mfa_factors ( id uuid NOT NULL, user_id uuid NOT NULL, friendly_name text NULL, "factor_type" auth."factor_type" NOT NULL, status auth."factor_status" NOT NULL, created_at timestamptz NOT NULL, updated_at timestamptz NOT NULL, secret text NULL, phone text NULL, last_challenged_at timestamptz NULL, web_authn_credential jsonb NULL, web_authn_aaguid uuid NULL, last_webauthn_challenge_data jsonb NULL, CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at), CONSTRAINT mfa_factors_pkey PRIMARY KEY (id), CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);
CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);
CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);
CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);
COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';

-- Column comments

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';

-- Permissions

ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_factors TO postgres;
GRANT ALL ON TABLE auth.mfa_factors TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;
GRANT SELECT ON TABLE auth.mfa_factors TO anon;
GRANT SELECT ON TABLE auth.mfa_factors TO authenticated;
GRANT SELECT ON TABLE auth.mfa_factors TO service_role;


-- auth.oauth_authorizations definição

-- Drop table

-- DROP TABLE auth.oauth_authorizations;

CREATE TABLE auth.oauth_authorizations ( id uuid NOT NULL, authorization_id text NOT NULL, client_id uuid NOT NULL, user_id uuid NULL, redirect_uri text NOT NULL, "scope" text NOT NULL, state text NULL, resource text NULL, code_challenge text NULL, "code_challenge_method" auth."code_challenge_method" NULL, response_type auth."oauth_response_type" DEFAULT 'code'::auth.oauth_response_type NOT NULL, status auth."oauth_authorization_status" DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL, authorization_code text NULL, created_at timestamptz DEFAULT now() NOT NULL, expires_at timestamptz DEFAULT now() + '00:03:00'::interval NOT NULL, approved_at timestamptz NULL, nonce text NULL, CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code), CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)), CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id), CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)), CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)), CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)), CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id), CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)), CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)), CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)), CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096)), CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE, CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);

-- Permissions

ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


-- auth.oauth_consents definição

-- Drop table

-- DROP TABLE auth.oauth_consents;

CREATE TABLE auth.oauth_consents ( id uuid NOT NULL, user_id uuid NOT NULL, client_id uuid NOT NULL, scopes text NOT NULL, granted_at timestamptz DEFAULT now() NOT NULL, revoked_at timestamptz NULL, CONSTRAINT oauth_consents_pkey PRIMARY KEY (id), CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))), CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)), CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0)), CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id), CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE, CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);
CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);
CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);

-- Permissions

ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO supabase_auth_admin;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


-- auth.one_time_tokens definição

-- Drop table

-- DROP TABLE auth.one_time_tokens;

CREATE TABLE auth.one_time_tokens ( id uuid NOT NULL, user_id uuid NOT NULL, token_type auth."one_time_token_type" NOT NULL, token_hash text NOT NULL, relates_to text NOT NULL, created_at timestamp DEFAULT now() NOT NULL, updated_at timestamp DEFAULT now() NOT NULL, CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id), CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0)), CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);
CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);
CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);

-- Permissions

ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.one_time_tokens TO postgres;
GRANT ALL ON TABLE auth.one_time_tokens TO supabase_auth_admin;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;
GRANT SELECT ON TABLE auth.one_time_tokens TO anon;
GRANT SELECT ON TABLE auth.one_time_tokens TO authenticated;
GRANT SELECT ON TABLE auth.one_time_tokens TO service_role;


-- auth.saml_providers definição

-- Drop table

-- DROP TABLE auth.saml_providers;

CREATE TABLE auth.saml_providers ( id uuid NOT NULL, sso_provider_id uuid NOT NULL, entity_id text NOT NULL, metadata_xml text NOT NULL, metadata_url text NULL, attribute_mapping jsonb NULL, created_at timestamptz NULL, updated_at timestamptz NULL, name_id_format text NULL, CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)), CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))), CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0)), CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id), CONSTRAINT saml_providers_pkey PRIMARY KEY (id), CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE);
CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);
COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';

-- Permissions

ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.saml_providers TO postgres;
GRANT ALL ON TABLE auth.saml_providers TO supabase_auth_admin;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;
GRANT SELECT ON TABLE auth.saml_providers TO anon;
GRANT SELECT ON TABLE auth.saml_providers TO authenticated;
GRANT SELECT ON TABLE auth.saml_providers TO service_role;


-- auth.saml_relay_states definição

-- Drop table

-- DROP TABLE auth.saml_relay_states;

CREATE TABLE auth.saml_relay_states ( id uuid NOT NULL, sso_provider_id uuid NOT NULL, request_id text NOT NULL, for_email text NULL, redirect_to text NULL, created_at timestamptz NULL, updated_at timestamptz NULL, flow_state_id uuid NULL, CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0)), CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id), CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE, CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE);
CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);
CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);
CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);
COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';

-- Permissions

ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.saml_relay_states TO postgres;
GRANT ALL ON TABLE auth.saml_relay_states TO supabase_auth_admin;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;
GRANT SELECT ON TABLE auth.saml_relay_states TO anon;
GRANT SELECT ON TABLE auth.saml_relay_states TO authenticated;
GRANT SELECT ON TABLE auth.saml_relay_states TO service_role;


-- auth.sessions definição

-- Drop table

-- DROP TABLE auth.sessions;

CREATE TABLE auth.sessions ( id uuid NOT NULL, user_id uuid NOT NULL, created_at timestamptz NULL, updated_at timestamptz NULL, factor_id uuid NULL, aal auth."aal_level" NULL, not_after timestamptz NULL, refreshed_at timestamp NULL, user_agent text NULL, ip inet NULL, tag text NULL, oauth_client_id uuid NULL, refresh_token_hmac_key text NULL, refresh_token_counter int8 NULL, scopes text NULL, CONSTRAINT sessions_pkey PRIMARY KEY (id), CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096)), CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE, CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE);
CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);
CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);
CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);
CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);
COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';

-- Column comments

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';
COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';
COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';

-- Permissions

ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sessions TO postgres;
GRANT ALL ON TABLE auth.sessions TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;
GRANT SELECT ON TABLE auth.sessions TO anon;
GRANT SELECT ON TABLE auth.sessions TO authenticated;
GRANT SELECT ON TABLE auth.sessions TO service_role;


-- auth.sso_domains definição

-- Drop table

-- DROP TABLE auth.sso_domains;

CREATE TABLE auth.sso_domains ( id uuid NOT NULL, sso_provider_id uuid NOT NULL, "domain" text NOT NULL, created_at timestamptz NULL, updated_at timestamptz NULL, CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0)), CONSTRAINT sso_domains_pkey PRIMARY KEY (id), CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE);
CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));
CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);
COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';

-- Permissions

ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sso_domains TO postgres;
GRANT ALL ON TABLE auth.sso_domains TO supabase_auth_admin;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;
GRANT SELECT ON TABLE auth.sso_domains TO anon;
GRANT SELECT ON TABLE auth.sso_domains TO authenticated;
GRANT SELECT ON TABLE auth.sso_domains TO service_role;


-- auth.mfa_amr_claims definição

-- Drop table

-- DROP TABLE auth.mfa_amr_claims;

CREATE TABLE auth.mfa_amr_claims ( session_id uuid NOT NULL, created_at timestamptz NOT NULL, updated_at timestamptz NOT NULL, authentication_method text NOT NULL, id uuid NOT NULL, CONSTRAINT amr_id_pk PRIMARY KEY (id), CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method), CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE);
COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';

-- Permissions

ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_amr_claims TO postgres;
GRANT ALL ON TABLE auth.mfa_amr_claims TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO anon;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO authenticated;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO service_role;


-- auth.mfa_challenges definição

-- Drop table

-- DROP TABLE auth.mfa_challenges;

CREATE TABLE auth.mfa_challenges ( id uuid NOT NULL, factor_id uuid NOT NULL, created_at timestamptz NOT NULL, verified_at timestamptz NULL, ip_address inet NOT NULL, otp_code text NULL, web_authn_session_data jsonb NULL, CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id), CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE);
CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);
COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';

-- Permissions

ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_challenges TO postgres;
GRANT ALL ON TABLE auth.mfa_challenges TO supabase_auth_admin;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;
GRANT SELECT ON TABLE auth.mfa_challenges TO anon;
GRANT SELECT ON TABLE auth.mfa_challenges TO authenticated;
GRANT SELECT ON TABLE auth.mfa_challenges TO service_role;


-- auth.refresh_tokens definição

-- Drop table

-- DROP TABLE auth.refresh_tokens;

CREATE TABLE auth.refresh_tokens ( instance_id uuid NULL, id bigserial NOT NULL, "token" varchar(255) NULL, user_id varchar(255) NULL, revoked bool NULL, created_at timestamptz NULL, updated_at timestamptz NULL, parent varchar(255) NULL, session_id uuid NULL, CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id), CONSTRAINT refresh_tokens_token_unique UNIQUE (token), CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE);
CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);
CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);
CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);
CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);
COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- Permissions

ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;
GRANT ALL ON TABLE auth.refresh_tokens TO supabase_auth_admin;
GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT ALL ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO anon;
GRANT SELECT ON TABLE auth.refresh_tokens TO authenticated;
GRANT SELECT ON TABLE auth.refresh_tokens TO service_role;



-- DROP FUNCTION auth.email();

CREATE OR REPLACE FUNCTION auth.email()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$function$
;

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';

-- Permissions

ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.email() TO public;
GRANT ALL ON FUNCTION auth.email() TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.email() TO dashboard_user;

-- DROP FUNCTION auth.jwt();

CREATE OR REPLACE FUNCTION auth.jwt()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$function$
;

-- Permissions

ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.jwt() TO public;
GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;

-- DROP FUNCTION auth."role"();

CREATE OR REPLACE FUNCTION auth.role()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$function$
;

COMMENT ON FUNCTION auth."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';

-- Permissions

ALTER FUNCTION auth."role"() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth."role"() TO public;
GRANT ALL ON FUNCTION auth."role"() TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth."role"() TO dashboard_user;

-- DROP FUNCTION auth.uid();

CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$function$
;

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';

-- Permissions

ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.uid() TO public;
GRANT ALL ON FUNCTION auth.uid() TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


-- Permissions

GRANT ALL ON SCHEMA auth TO supabase_admin;
GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT EXECUTE ON FUNCTIONS TO dashboard_user;

-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION postgres;

-- DROP TYPE public."documento_fiscal_status";

CREATE TYPE public."documento_fiscal_status" AS ENUM (
	'SEM_DOCUMENTO_FISCAL',
	'PENDENTE_EMISSAO',
	'EMITIDA_NFCE',
	'EMITIDA_NFE',
	'REJEITADA_SEFAZ',
	'CANCELADA');

-- DROP TYPE public."pagamento_forma";

CREATE TYPE public."pagamento_forma" AS ENUM (
	'DINHEIRO',
	'CARTAO_CREDITO',
	'CARTAO_DEBITO',
	'PIX',
	'CHEQUE',
	'VALE',
	'PRAZO');

-- DROP TYPE public."unidade_medida";

CREATE TYPE public."unidade_medida" AS ENUM (
	'UN',
	'CX',
	'FD',
	'DZ',
	'L',
	'KG',
	'PCT');

-- DROP TYPE public."user_role";

CREATE TYPE public."user_role" AS ENUM (
	'ADMIN',
	'GERENTE',
	'VENDEDOR',
	'OPERADOR_CAIXA',
	'ESTOQUISTA',
	'COMPRADOR',
	'APROVADOR');

-- DROP TYPE public."venda_status";

CREATE TYPE public."venda_status" AS ENUM (
	'ABERTA',
	'FINALIZADA',
	'CANCELADA',
	'DEVOLVIDA');

-- DROP SEQUENCE public.vendas_numero_seq;

CREATE SEQUENCE public.vendas_numero_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1001
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE public.vendas_numero_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE public.vendas_numero_seq TO postgres;
GRANT USAGE ON SEQUENCE public.vendas_numero_seq TO anon;
GRANT USAGE ON SEQUENCE public.vendas_numero_seq TO authenticated;
GRANT USAGE ON SEQUENCE public.vendas_numero_seq TO service_role;
-- public.caixas definição

-- Drop table

-- DROP TABLE public.caixas;

CREATE TABLE public.caixas ( id uuid DEFAULT uuid_generate_v4() NOT NULL, numero int4 NOT NULL, descricao varchar(100) NULL, serie_pdv varchar(20) NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, nome varchar(100) NULL, impressora_nfce varchar(100) NULL, impressora_cupom varchar(100) NULL, terminal varchar(100) NULL, CONSTRAINT caixas_numero_key UNIQUE (numero), CONSTRAINT caixas_pkey PRIMARY KEY (id));
CREATE INDEX idx_caixas_ativo ON public.caixas USING btree (ativo);
CREATE INDEX idx_caixas_numero ON public.caixas USING btree (numero);

-- Permissions

ALTER TABLE public.caixas OWNER TO postgres;
GRANT ALL ON TABLE public.caixas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixas TO service_role;


-- public.categorias definição

-- Drop table

-- DROP TABLE public.categorias;

CREATE TABLE public.categorias ( id uuid DEFAULT uuid_generate_v4() NOT NULL, nome varchar(100) NOT NULL, descricao text NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT categorias_nome_key UNIQUE (nome), CONSTRAINT categorias_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE public.categorias OWNER TO postgres;
GRANT ALL ON TABLE public.categorias TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categorias TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categorias TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categorias TO service_role;


-- public.clientes definição

-- Drop table

-- DROP TABLE public.clientes;

CREATE TABLE public.clientes ( id uuid DEFAULT uuid_generate_v4() NOT NULL, nome varchar(255) NOT NULL, tipo varchar(10) NULL, cpf_cnpj varchar(18) NULL, inscricao_estadual varchar(20) NULL, endereco text NULL, numero varchar(10) NULL, complemento text NULL, bairro varchar(100) NULL, cidade varchar(100) NULL, estado varchar(2) NULL, cep varchar(10) NULL, telefone varchar(20) NULL, whatsapp varchar(20) NULL, email varchar(100) NULL, limite_credito numeric(12, 2) DEFAULT 0.00 NULL, saldo_devedor numeric(12, 2) DEFAULT 0.00 NULL, tabela_preco_custom bool DEFAULT false NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT clientes_cpf_cnpj_key UNIQUE (cpf_cnpj), CONSTRAINT clientes_pkey PRIMARY KEY (id));
CREATE INDEX idx_clientes_ativo ON public.clientes USING btree (ativo);

-- Table Triggers

create trigger update_clientes_updated_at before
update
    on
    public.clientes for each row execute function update_updated_at_column();

-- Permissions

ALTER TABLE public.clientes OWNER TO postgres;
GRANT ALL ON TABLE public.clientes TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.clientes TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.clientes TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.clientes TO service_role;


-- public.empresa_config definição

-- Drop table

-- DROP TABLE public.empresa_config;

CREATE TABLE public.empresa_config ( id uuid DEFAULT uuid_generate_v4() NOT NULL, nome_empresa varchar(200) NOT NULL, razao_social varchar(200) NULL, cnpj varchar(18) NULL, inscricao_estadual varchar(20) NULL, inscricao_municipal varchar(20) NULL, logo_url text NULL, endereco text NULL, numero varchar(10) NULL, complemento text NULL, bairro varchar(100) NULL, cidade varchar(100) NULL, estado varchar(2) NULL, cep varchar(10) NULL, telefone varchar(20) NULL, email varchar(100) NULL, website varchar(200) NULL, regime_tributario varchar(1) NULL, cnae varchar(10) NULL, codigo_municipio varchar(7) NULL, logradouro varchar(255) NULL, nfe_ambiente varchar(1) DEFAULT '2'::character varying NULL, nfe_token text NULL, nfce_serie int4 DEFAULT 1 NULL, nfe_serie int4 DEFAULT 1 NULL, nfce_numero int4 DEFAULT 1 NULL, nfe_numero int4 DEFAULT 1 NULL, pdv_emitir_nfce bool DEFAULT false NULL, pdv_imprimir_cupom bool DEFAULT true NULL, pdv_permitir_venda_zerado bool DEFAULT false NULL, pdv_desconto_maximo bool DEFAULT false NULL, pdv_desconto_limite numeric(5, 2) DEFAULT 10.00 NULL, pdv_mensagem_cupom text NULL, whatsapp_api_provider varchar(50) NULL, whatsapp_numero_origem varchar(20) NULL, whatsapp_api_url text NULL, whatsapp_api_key text NULL, whatsapp_instance_id varchar(100) NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, certificado_digital text NULL, senha_certificado varchar(255) NULL, regime_tributario_codigo varchar(1) NULL, natureza_operacao_padrao varchar(150) DEFAULT 'VENDA'::character varying NULL, sincronizar_numero_nfce bool DEFAULT true NULL, ultimo_numero_nfce_sincronizado int4 DEFAULT 0 NULL, endereco_numero varchar(20) NULL, csc_id varchar(50) NULL, csc_token varchar(100) NULL, ambiente_nfe varchar(1) DEFAULT '2'::character varying NULL, serie_nfe varchar(5) DEFAULT '1'::character varying NULL, proximo_numero_nfe int4 DEFAULT 1 NULL, cor_primaria varchar(7) DEFAULT '#3B82F6'::character varying NULL, cor_secundaria varchar(7) DEFAULT '#10B981'::character varying NULL, habilitar_cupom_fiscal bool DEFAULT false NULL, habilitar_nfce bool DEFAULT false NULL, alerta_estoque_minimo bool DEFAULT true NULL, dias_alerta_validade int4 DEFAULT 30 NULL, focusnfe_token text NULL, focusnfe_ambiente int4 DEFAULT 2 NULL, certificado_validade date NULL, pdv_emitir_nfce_automatico bool DEFAULT false NULL, focusnfe_token_homologacao text NULL, api_fiscal_provider varchar(20) DEFAULT 'focus_nfe'::character varying NULL, nuvemfiscal_client_id text NULL, nuvemfiscal_client_secret text NULL, nuvemfiscal_access_token text NULL, nuvemfiscal_token_expiry timestamp NULL, impressora_nfce_padrao varchar NULL, impressora_cupom_padrao varchar NULL, nuvemfiscal_ambiente int4 DEFAULT 2 NULL, CONSTRAINT empresa_config_api_fiscal_provider_check CHECK (((api_fiscal_provider)::text = ANY ((ARRAY['focus_nfe'::character varying, 'nuvem_fiscal'::character varying])::text[]))), CONSTRAINT empresa_config_cnpj_key UNIQUE (cnpj), CONSTRAINT empresa_config_pkey PRIMARY KEY (id));
CREATE INDEX idx_empresa_config_api_provider ON public.empresa_config USING btree (api_fiscal_provider);

-- Column comments

COMMENT ON COLUMN public.empresa_config.nfce_serie IS 'Série utilizada para emissão de NFC-e';
COMMENT ON COLUMN public.empresa_config.nfe_serie IS 'Série utilizada para emissão de NF-e';
COMMENT ON COLUMN public.empresa_config.nfce_numero IS 'Próximo número sequencial de NFC-e';
COMMENT ON COLUMN public.empresa_config.nfe_numero IS 'Próximo número sequencial de NF-e';
COMMENT ON COLUMN public.empresa_config.csc_id IS 'ID do Código de Segurança do Contribuinte (NFC-e)';
COMMENT ON COLUMN public.empresa_config.csc_token IS 'Token do Código de Segurança do Contribuinte (NFC-e)';
COMMENT ON COLUMN public.empresa_config.focusnfe_token IS 'Token Focus NFe para ambiente de PRODUÇÃO';
COMMENT ON COLUMN public.empresa_config.focusnfe_ambiente IS '1=Produção, 2=Homologação';
COMMENT ON COLUMN public.empresa_config.certificado_validade IS 'Data de validade do certificado digital A1';
COMMENT ON COLUMN public.empresa_config.pdv_emitir_nfce_automatico IS 'Se true, emite NFC-e automaticamente ao finalizar venda no PDV';
COMMENT ON COLUMN public.empresa_config.focusnfe_token_homologacao IS 'Token Focus NFe para ambiente de HOMOLOGAÇÃO';
COMMENT ON COLUMN public.empresa_config.api_fiscal_provider IS 'Provedor de API fiscal a ser utilizado: focus_nfe ou nuvem_fiscal';
COMMENT ON COLUMN public.empresa_config.nuvemfiscal_client_id IS 'Client ID da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN public.empresa_config.nuvemfiscal_client_secret IS 'Client Secret da API Nuvem Fiscal (OAuth2)';
COMMENT ON COLUMN public.empresa_config.nuvemfiscal_access_token IS 'Access Token OAuth2 em cache';
COMMENT ON COLUMN public.empresa_config.nuvemfiscal_token_expiry IS 'Data/hora de expiração do access token';
COMMENT ON COLUMN public.empresa_config.impressora_nfce_padrao IS 'Nome da impressora fiscal padrão para NFC-e. Usado quando o caixa não tem impressora específica configurada.';
COMMENT ON COLUMN public.empresa_config.impressora_cupom_padrao IS 'Nome da impressora térmica padrão para cupons. Usado quando o caixa não tem impressora específica configurada.';

-- Table Triggers

create trigger update_empresa_config_updated_at before
update
    on
    public.empresa_config for each row execute function update_updated_at_column();

-- Permissions

ALTER TABLE public.empresa_config OWNER TO postgres;
GRANT ALL ON TABLE public.empresa_config TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.empresa_config TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.empresa_config TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.empresa_config TO service_role;


-- public.estoque_backups definição

-- Drop table

-- DROP TABLE public.estoque_backups;

CREATE TABLE public.estoque_backups ( id uuid DEFAULT gen_random_uuid() NOT NULL, data_backup timestamptz DEFAULT now() NULL, total_produtos int4 NULL, total_unidades numeric NULL, dados_backup jsonb NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT estoque_backups_pkey PRIMARY KEY (id));
CREATE INDEX idx_estoque_backups_data_backup ON public.estoque_backups USING btree (data_backup DESC);
COMMENT ON TABLE public.estoque_backups IS 'Backup de estoque antes de reprocessamento - contém snapshot JSON dos produtos e suas quantidades';

-- Permissions

ALTER TABLE public.estoque_backups OWNER TO postgres;
GRANT ALL ON TABLE public.estoque_backups TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_backups TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_backups TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_backups TO service_role;


-- public.fornecedores definição

-- Drop table

-- DROP TABLE public.fornecedores;

CREATE TABLE public.fornecedores ( id uuid DEFAULT uuid_generate_v4() NOT NULL, nome varchar(255) NOT NULL, cnpj varchar(18) NULL, inscricao_estadual varchar(20) NULL, endereco text NULL, numero varchar(10) NULL, bairro varchar(100) NULL, cidade varchar(100) NULL, estado varchar(2) NULL, cep varchar(10) NULL, telefone varchar(20) NULL, email varchar(100) NULL, contato_nome varchar(255) NULL, contato_telefone varchar(20) NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, razao_social varchar(150) NOT NULL, nome_fantasia varchar(150) NULL, complemento varchar(100) NULL, usuario_id uuid NULL, site varchar(200) NULL, banco varchar(100) NULL, agencia varchar(20) NULL, conta varchar(30) NULL, pix varchar(100) NULL, observacoes text NULL, CONSTRAINT fornecedores_cnpj_key UNIQUE (cnpj), CONSTRAINT fornecedores_pkey PRIMARY KEY (id));
CREATE INDEX idx_fornecedores_ativo ON public.fornecedores USING btree (ativo);
CREATE INDEX idx_fornecedores_cnpj ON public.fornecedores USING btree (cnpj);
CREATE INDEX idx_fornecedores_razao_social ON public.fornecedores USING btree (razao_social);

-- Permissions

ALTER TABLE public.fornecedores OWNER TO postgres;
GRANT ALL ON TABLE public.fornecedores TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.fornecedores TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.fornecedores TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.fornecedores TO service_role;


-- public.marcas definição

-- Drop table

-- DROP TABLE public.marcas;

CREATE TABLE public.marcas ( id uuid DEFAULT uuid_generate_v4() NOT NULL, nome varchar(100) NOT NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, descricao text NULL, CONSTRAINT marcas_nome_key UNIQUE (nome), CONSTRAINT marcas_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE public.marcas OWNER TO postgres;
GRANT ALL ON TABLE public.marcas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.marcas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.marcas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.marcas TO service_role;


-- public.modulos definição

-- Drop table

-- DROP TABLE public.modulos;

CREATE TABLE public.modulos ( id uuid DEFAULT gen_random_uuid() NOT NULL, nome text NOT NULL, descricao text NULL, slug text NOT NULL, icone text NULL, ordem int4 DEFAULT 0 NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT modulos_nome_key UNIQUE (nome), CONSTRAINT modulos_pkey PRIMARY KEY (id), CONSTRAINT modulos_slug_key UNIQUE (slug));

-- Permissions

ALTER TABLE public.modulos OWNER TO postgres;
GRANT ALL ON TABLE public.modulos TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.modulos TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.modulos TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.modulos TO service_role;


-- public.users definição

-- Drop table

-- DROP TABLE public.users;

CREATE TABLE public.users ( id uuid DEFAULT uuid_generate_v4() NOT NULL, email varchar(255) NOT NULL, nome_completo varchar(255) NOT NULL, cpf varchar(14) NULL, "role" public."user_role" DEFAULT 'VENDEDOR'::user_role NOT NULL, telefone varchar(20) NULL, whatsapp varchar(20) NULL, ativo bool DEFAULT true NULL, email_confirmado bool DEFAULT false NULL, ultimo_login timestamptz NULL, senha_hash varchar(255) NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, full_name varchar(255) NULL, approved bool DEFAULT false NULL, approved_by uuid NULL, approved_at timestamptz NULL, CONSTRAINT users_cpf_key UNIQUE (cpf), CONSTRAINT users_email_key UNIQUE (email), CONSTRAINT users_pkey PRIMARY KEY (id));
CREATE INDEX idx_users_ativo ON public.users USING btree (ativo);
CREATE INDEX idx_users_email ON public.users USING btree (email);
CREATE INDEX idx_users_role ON public.users USING btree (role);

-- Table Triggers

create trigger update_users_updated_at before
update
    on
    public.users for each row execute function update_updated_at_column();

-- Permissions

ALTER TABLE public.users OWNER TO postgres;
GRANT ALL ON TABLE public.users TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.users TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.users TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.users TO service_role;


-- public.venda_itens definição

-- Drop table

-- DROP TABLE public.venda_itens;

CREATE TABLE public.venda_itens ( id uuid DEFAULT uuid_generate_v4() NOT NULL, venda_id uuid NOT NULL, produto_id uuid NOT NULL, lote_id uuid NULL, quantidade numeric(12, 3) NOT NULL, preco_unitario numeric(12, 2) NOT NULL, desconto_percentual numeric(5, 2) DEFAULT 0 NULL, desconto_valor numeric(12, 2) DEFAULT 0 NULL, subtotal numeric(12, 2) NOT NULL, cfop varchar(10) NULL, ncm varchar(10) NULL, cst_icms varchar(5) NULL, valor_icms numeric(12, 2) DEFAULT 0 NULL, created_at timestamptz DEFAULT now() NULL, preco_custo numeric(12, 2) NULL, CONSTRAINT venda_itens_pkey PRIMARY KEY (id));
CREATE INDEX idx_venda_itens_lote ON public.venda_itens USING btree (lote_id);
CREATE INDEX idx_venda_itens_produto ON public.venda_itens USING btree (produto_id);
CREATE INDEX idx_venda_itens_venda ON public.venda_itens USING btree (venda_id);

-- Column comments

COMMENT ON COLUMN public.venda_itens.preco_custo IS 'Preço de custo no momento da venda - usado para análise de lucro';

-- Table Triggers

create trigger trg_before_insert_venda_item_custo before
insert
    on
    public.venda_itens for each row execute function trg_venda_item_set_preco_custo();

-- Permissions

ALTER TABLE public.venda_itens OWNER TO postgres;
GRANT ALL ON TABLE public.venda_itens TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_itens TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_itens TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_itens TO service_role;


-- public.venda_pagamentos definição

-- Drop table

-- DROP TABLE public.venda_pagamentos;

CREATE TABLE public.venda_pagamentos ( id uuid NOT NULL, venda_id uuid NOT NULL, forma_pagamento varchar(30) NOT NULL, valor numeric(12, 2) NOT NULL, bandeira varchar(50) NULL, nsu varchar(50) NULL, autorizacao varchar(50) NULL, parcelas int4 DEFAULT 1 NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT venda_pagamentos_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE public.venda_pagamentos OWNER TO postgres;
GRANT ALL ON TABLE public.venda_pagamentos TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_pagamentos TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_pagamentos TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.venda_pagamentos TO service_role;


-- public.acoes_modulo definição

-- Drop table

-- DROP TABLE public.acoes_modulo;

CREATE TABLE public.acoes_modulo ( id uuid DEFAULT gen_random_uuid() NOT NULL, modulo_id uuid NOT NULL, nome text NOT NULL, descricao text NULL, slug text NOT NULL, CONSTRAINT acoes_modulo_modulo_id_slug_key UNIQUE (modulo_id, slug), CONSTRAINT acoes_modulo_pkey PRIMARY KEY (id), CONSTRAINT acoes_modulo_modulo_id_fkey FOREIGN KEY (modulo_id) REFERENCES public.modulos(id) ON DELETE CASCADE);
CREATE INDEX idx_acoes_modulo_modulo ON public.acoes_modulo USING btree (modulo_id);

-- Permissions

ALTER TABLE public.acoes_modulo OWNER TO postgres;
GRANT ALL ON TABLE public.acoes_modulo TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.acoes_modulo TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.acoes_modulo TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.acoes_modulo TO service_role;


-- public.aliquotas_estaduais definição

-- Drop table

-- DROP TABLE public.aliquotas_estaduais;

CREATE TABLE public.aliquotas_estaduais ( id uuid DEFAULT uuid_generate_v4() NOT NULL, estado_origem varchar(2) NOT NULL, estado_destino varchar(2) NOT NULL, categoria_id uuid NULL, aliquota_icms numeric(5, 2) DEFAULT 0.00 NULL, aliquota_pis numeric(5, 2) DEFAULT 0.00 NULL, aliquota_cofins numeric(5, 2) DEFAULT 0.00 NULL, vigencia_inicio date NOT NULL, vigencia_fim date NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT aliquotas_estaduais_estado_origem_estado_destino_categoria__key UNIQUE (estado_origem, estado_destino, categoria_id, vigencia_inicio), CONSTRAINT aliquotas_estaduais_pkey PRIMARY KEY (id), CONSTRAINT aliquotas_estaduais_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id));

-- Permissions

ALTER TABLE public.aliquotas_estaduais OWNER TO postgres;
GRANT ALL ON TABLE public.aliquotas_estaduais TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.aliquotas_estaduais TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.aliquotas_estaduais TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.aliquotas_estaduais TO service_role;


-- public.auditoria_log definição

-- Drop table

-- DROP TABLE public.auditoria_log;

CREATE TABLE public.auditoria_log ( id uuid DEFAULT uuid_generate_v4() NOT NULL, tabela_nome varchar(100) NOT NULL, operacao varchar(10) NOT NULL, registro_id uuid NULL, dados_antigos jsonb NULL, dados_novos jsonb NULL, usuario_id uuid NULL, ip_address varchar(45) NULL, user_agent text NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT auditoria_log_pkey PRIMARY KEY (id), CONSTRAINT auditoria_log_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id));
CREATE INDEX idx_auditoria_data ON public.auditoria_log USING btree (created_at DESC);
CREATE INDEX idx_auditoria_tabela ON public.auditoria_log USING btree (tabela_nome);
CREATE INDEX idx_auditoria_usuario ON public.auditoria_log USING btree (usuario_id);

-- Permissions

ALTER TABLE public.auditoria_log OWNER TO postgres;
GRANT ALL ON TABLE public.auditoria_log TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.auditoria_log TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.auditoria_log TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.auditoria_log TO service_role;


-- public.caixa_sessoes definição

-- Drop table

-- DROP TABLE public.caixa_sessoes;

CREATE TABLE public.caixa_sessoes ( caixa_id uuid NULL, operador_id uuid NULL, data_abertura timestamptz DEFAULT now() NULL, data_fechamento timestamptz NULL, valor_abertura numeric(12, 2) DEFAULT 0 NULL, valor_fechamento numeric(12, 2) NULL, valor_vendas numeric(12, 2) DEFAULT 0 NULL, valor_sangrias numeric(12, 2) DEFAULT 0 NULL, valor_suprimentos numeric(12, 2) DEFAULT 0 NULL, diferenca numeric(12, 2) NULL, status varchar(20) DEFAULT 'ABERTO'::character varying NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, id uuid DEFAULT uuid_generate_v4() NOT NULL, CONSTRAINT caixa_sessoes_pkey PRIMARY KEY (id), CONSTRAINT caixa_sessoes_status_check CHECK (((status)::text = ANY ((ARRAY['ABERTO'::character varying, 'FECHADO'::character varying, 'CONFERIDO'::character varying])::text[]))), CONSTRAINT fk_caixa_sessoes_caixa FOREIGN KEY (caixa_id) REFERENCES public.caixas(id), CONSTRAINT fk_caixa_sessoes_operador FOREIGN KEY (operador_id) REFERENCES public.users(id));
CREATE INDEX idx_caixa_sessoes_caixa_id ON public.caixa_sessoes USING btree (caixa_id);
CREATE INDEX idx_caixa_sessoes_data ON public.caixa_sessoes USING btree (data_abertura DESC);
CREATE INDEX idx_caixa_sessoes_data_abertura ON public.caixa_sessoes USING btree (data_abertura);
CREATE INDEX idx_caixa_sessoes_operador_id ON public.caixa_sessoes USING btree (operador_id);
CREATE INDEX idx_sessoes_caixa ON public.caixa_sessoes USING btree (caixa_id);
CREATE INDEX idx_sessoes_operador ON public.caixa_sessoes USING btree (operador_id);
CREATE INDEX idx_sessoes_status ON public.caixa_sessoes USING btree (status);

-- Permissions

ALTER TABLE public.caixa_sessoes OWNER TO postgres;
GRANT ALL ON TABLE public.caixa_sessoes TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_sessoes TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_sessoes TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_sessoes TO service_role;


-- public.categoria_impostos definição

-- Drop table

-- DROP TABLE public.categoria_impostos;

CREATE TABLE public.categoria_impostos ( id uuid DEFAULT uuid_generate_v4() NOT NULL, categoria_id uuid NOT NULL, aliquota_icms numeric(5, 2) DEFAULT 0.00 NULL, aliquota_pis numeric(5, 2) DEFAULT 0.00 NULL, aliquota_cofins numeric(5, 2) DEFAULT 0.00 NULL, aliquota_ipi numeric(5, 2) DEFAULT 0.00 NULL, cst_icms varchar(3) DEFAULT '00'::character varying NULL, ncm_padrao varchar(8) NULL, cfop_padrao varchar(4) DEFAULT '5102'::character varying NULL, origem_padrao varchar(1) DEFAULT '0'::character varying NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT categoria_impostos_categoria_id_key UNIQUE (categoria_id), CONSTRAINT categoria_impostos_pkey PRIMARY KEY (id), CONSTRAINT categoria_impostos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE public.categoria_impostos OWNER TO postgres;
GRANT ALL ON TABLE public.categoria_impostos TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categoria_impostos TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categoria_impostos TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.categoria_impostos TO service_role;


-- public.importacao_xml_log definição

-- Drop table

-- DROP TABLE public.importacao_xml_log;

CREATE TABLE public.importacao_xml_log ( id uuid DEFAULT uuid_generate_v4() NOT NULL, arquivo_nome varchar(255) NOT NULL, chave_nfe varchar(44) NULL, numero_nfe varchar(20) NULL, fornecedor_id uuid NULL, fornecedor_cnpj varchar(18) NULL, fornecedor_nome varchar(255) NULL, pedido_id uuid NULL, total_produtos int4 DEFAULT 0 NULL, valor_total numeric(10, 2) DEFAULT 0 NULL, status varchar(20) DEFAULT 'PROCESSANDO'::character varying NULL, erro_mensagem text NULL, created_by uuid NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT importacao_xml_log_pkey PRIMARY KEY (id), CONSTRAINT importacao_xml_log_status_check CHECK (((status)::text = ANY ((ARRAY['PROCESSANDO'::character varying, 'SUCESSO'::character varying, 'ERRO'::character varying, 'PARCIAL'::character varying])::text[]))), CONSTRAINT fk_importacao_xml_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id), CONSTRAINT fk_importacao_xml_user FOREIGN KEY (created_by) REFERENCES public.users(id));
CREATE INDEX idx_importacao_xml_log_chave ON public.importacao_xml_log USING btree (chave_nfe);
CREATE INDEX idx_importacao_xml_log_created ON public.importacao_xml_log USING btree (created_at DESC);
CREATE INDEX idx_importacao_xml_log_fornecedor ON public.importacao_xml_log USING btree (fornecedor_id);
CREATE INDEX idx_importacao_xml_log_pedido ON public.importacao_xml_log USING btree (pedido_id);
CREATE INDEX idx_importacao_xml_log_status ON public.importacao_xml_log USING btree (status);

-- Permissions

ALTER TABLE public.importacao_xml_log OWNER TO postgres;
GRANT ALL ON TABLE public.importacao_xml_log TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.importacao_xml_log TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.importacao_xml_log TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.importacao_xml_log TO service_role;


-- public.movimentacoes_caixa definição

-- Drop table

-- DROP TABLE public.movimentacoes_caixa;

CREATE TABLE public.movimentacoes_caixa ( id uuid DEFAULT uuid_generate_v4() NOT NULL, caixa_id uuid NOT NULL, data_abertura timestamptz DEFAULT now() NOT NULL, data_fechamento timestamptz NULL, operador_id uuid NOT NULL, saldo_inicial numeric(12, 2) DEFAULT 0.00 NOT NULL, total_vendas numeric(12, 2) DEFAULT 0.00 NULL, total_dinheiro numeric(12, 2) DEFAULT 0.00 NULL, total_sangria numeric(12, 2) DEFAULT 0.00 NULL, total_suprimento numeric(12, 2) DEFAULT 0.00 NULL, saldo_final numeric(12, 2) NULL, status varchar(20) DEFAULT 'ABERTA'::character varying NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT movimentacoes_caixa_pkey PRIMARY KEY (id), CONSTRAINT movimentacoes_caixa_caixa_id_fkey FOREIGN KEY (caixa_id) REFERENCES public.caixas(id), CONSTRAINT movimentacoes_caixa_operador_id_fkey FOREIGN KEY (operador_id) REFERENCES public.users(id));

-- Permissions

ALTER TABLE public.movimentacoes_caixa OWNER TO postgres;
GRANT ALL ON TABLE public.movimentacoes_caixa TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_caixa TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_caixa TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_caixa TO service_role;


-- public.pedidos_compra definição

-- Drop table

-- DROP TABLE public.pedidos_compra;

CREATE TABLE public.pedidos_compra ( id uuid NOT NULL, numero varchar(20) NOT NULL, fornecedor_id uuid NOT NULL, usuario_id uuid NOT NULL, subtotal numeric(12, 2) DEFAULT 0 NULL, desconto numeric(12, 2) DEFAULT 0 NULL, frete numeric(12, 2) DEFAULT 0 NULL, outras_despesas numeric(12, 2) DEFAULT 0 NULL, total numeric(12, 2) DEFAULT 0 NULL, data_pedido date DEFAULT CURRENT_DATE NULL, data_previsao date NULL, data_recebimento date NULL, nf_numero varchar(50) NULL, nf_serie varchar(10) NULL, nf_chave varchar(50) NULL, status varchar(20) DEFAULT 'PENDENTE'::character varying NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT pedidos_compra_numero_key UNIQUE (numero), CONSTRAINT pedidos_compra_pkey PRIMARY KEY (id), CONSTRAINT pedidos_compra_status_check CHECK (((status)::text = ANY ((ARRAY['PENDENTE'::character varying, 'APROVADO'::character varying, 'RECEBIDO'::character varying, 'CANCELADO'::character varying])::text[]))), CONSTRAINT pedidos_compra_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id) ON DELETE RESTRICT, CONSTRAINT pedidos_compra_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id) ON DELETE SET NULL);
CREATE INDEX idx_pedidos_compra_data ON public.pedidos_compra USING btree (data_pedido);
CREATE INDEX idx_pedidos_compra_fornecedor ON public.pedidos_compra USING btree (fornecedor_id);
CREATE INDEX idx_pedidos_compra_status ON public.pedidos_compra USING btree (status);
CREATE INDEX idx_pedidos_compra_usuario_id ON public.pedidos_compra USING btree (usuario_id);

-- Permissions

ALTER TABLE public.pedidos_compra OWNER TO postgres;
GRANT ALL ON TABLE public.pedidos_compra TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedidos_compra TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedidos_compra TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedidos_compra TO service_role;


-- public.permissoes_acoes_usuario definição

-- Drop table

-- DROP TABLE public.permissoes_acoes_usuario;

CREATE TABLE public.permissoes_acoes_usuario ( id uuid DEFAULT gen_random_uuid() NOT NULL, usuario_id uuid NOT NULL, acao_id uuid NOT NULL, permitida bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT permissoes_acoes_usuario_pkey PRIMARY KEY (id), CONSTRAINT permissoes_acoes_usuario_usuario_id_acao_id_key UNIQUE (usuario_id, acao_id), CONSTRAINT permissoes_acoes_usuario_acao_id_fkey FOREIGN KEY (acao_id) REFERENCES public.acoes_modulo(id) ON DELETE CASCADE);
CREATE INDEX idx_permissoes_acoes_usuario_usuario ON public.permissoes_acoes_usuario USING btree (usuario_id);

-- Permissions

ALTER TABLE public.permissoes_acoes_usuario OWNER TO postgres;
GRANT ALL ON TABLE public.permissoes_acoes_usuario TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.permissoes_acoes_usuario TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.permissoes_acoes_usuario TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.permissoes_acoes_usuario TO service_role;


-- public.produtos definição

-- Drop table

-- DROP TABLE public.produtos;

CREATE TABLE public.produtos ( id uuid DEFAULT uuid_generate_v4() NOT NULL, codigo_barras varchar(20) NULL, nome varchar(255) NOT NULL, descricao text NULL, categoria_id uuid NULL, marca_id uuid NULL, preco_custo numeric(12, 2) DEFAULT 0.00 NOT NULL, preco_venda numeric(12, 2) DEFAULT 0.00 NOT NULL, preco_atacado numeric(12, 2) NULL, margem_lucro numeric(5, 2) DEFAULT 0.00 NULL, unidade_medida_padrao public."unidade_medida" DEFAULT 'UN'::unidade_medida NULL, unidade_venda public."unidade_medida" DEFAULT 'UN'::unidade_medida NULL, quantidade_por_embalagem numeric(10, 2) DEFAULT 1.00 NULL, estoque_minimo numeric(10, 2) DEFAULT 0.00 NULL, estoque_maximo numeric(10, 2) DEFAULT 0.00 NULL, estoque_atual numeric(10, 2) DEFAULT 0.00 NULL, ativo bool DEFAULT true NULL, requer_lote bool DEFAULT false NULL, controla_serie bool DEFAULT false NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, ncm varchar(10) DEFAULT '22021000'::character varying NULL, cfop varchar(4) DEFAULT '5102'::character varying NULL, origem_produto varchar(1) DEFAULT '0'::character varying NULL, descricao_nfe text NULL, aliquota_icms numeric(5, 2) DEFAULT 0.00 NULL, aliquota_pis numeric(5, 2) DEFAULT 0.00 NULL, aliquota_cofins numeric(5, 2) DEFAULT 0.00 NULL, aliquota_ipi numeric(5, 2) DEFAULT 0.00 NULL, cst_icms varchar(10) DEFAULT '00'::character varying NULL, codigo varchar(50) NULL, marca varchar(100) NULL, unidade varchar(20) DEFAULT 'UN'::character varying NULL, fornecedor_id uuid NULL, imagem_url text NULL, volume_ml int4 NULL, controla_validade bool DEFAULT true NULL, cfop_compra varchar(10) DEFAULT '1102'::character varying NULL, cest varchar(10) NULL, cfop_venda varchar(10) DEFAULT '5102'::character varying NULL, cst_pis varchar(10) NULL, cst_cofins varchar(10) NULL, cst_ipi varchar(10) NULL, origem varchar(5) DEFAULT '0'::character varying NULL, embalagem varchar(50) NULL, quantidade_embalagem int4 DEFAULT 1 NULL, dias_alerta_validade int4 DEFAULT 30 NULL, localizacao varchar(50) NULL, peso_kg numeric(10, 3) NULL, sku varchar(50) NULL, exige_estoque bool DEFAULT true NOT NULL, CONSTRAINT produtos_codigo_barras_key UNIQUE (codigo_barras), CONSTRAINT produtos_pkey PRIMARY KEY (id), CONSTRAINT produtos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id), CONSTRAINT produtos_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marcas(id));
CREATE INDEX idx_produtos_ativo ON public.produtos USING btree (ativo);
CREATE INDEX idx_produtos_categoria ON public.produtos USING btree (categoria_id);
CREATE INDEX idx_produtos_categoria_id ON public.produtos USING btree (categoria_id);
CREATE INDEX idx_produtos_cest ON public.produtos USING btree (cest);
CREATE INDEX idx_produtos_cfop_compra ON public.produtos USING btree (cfop_compra);
CREATE INDEX idx_produtos_cfop_venda ON public.produtos USING btree (cfop_venda);
CREATE INDEX idx_produtos_codigo ON public.produtos USING btree (codigo);
CREATE INDEX idx_produtos_codigo_barras ON public.produtos USING btree (codigo_barras);
CREATE INDEX idx_produtos_cst_icms ON public.produtos USING btree (cst_icms);
CREATE INDEX idx_produtos_exige_estoque ON public.produtos USING btree (exige_estoque);
CREATE INDEX idx_produtos_fornecedor ON public.produtos USING btree (fornecedor_id);
CREATE INDEX idx_produtos_marca ON public.produtos USING btree (marca);
CREATE INDEX idx_produtos_marca_id ON public.produtos USING btree (marca_id);
CREATE INDEX idx_produtos_ncm ON public.produtos USING btree (ncm);
CREATE INDEX idx_produtos_nome ON public.produtos USING gin (to_tsvector('portuguese'::regconfig, (nome)::text));
COMMENT ON TABLE public.produtos IS 'Cadastro de produtos - estoque_atual é calculado, NÃO editar manualmente';

-- Column comments

COMMENT ON COLUMN public.produtos.preco_custo IS 'Preço de custo - atualizado automaticamente na entrada de compra';
COMMENT ON COLUMN public.produtos.estoque_atual IS 'Estoque atual - NUNCA editar manualmente, apenas via movimentações';
COMMENT ON COLUMN public.produtos.exige_estoque IS 'Se false, o produto não exigirá validação de estoque no PDV nem em pedidos de venda. Útil para serviços, vouchers, etc.';

-- Table Triggers

create trigger tr_validar_sku_insert before
insert
    on
    public.produtos for each row execute function validar_sku_unico();
create trigger tr_validar_sku_update before
update
    on
    public.produtos for each row execute function validar_sku_unico();
create trigger trigger_validar_estoque before
update
    on
    public.produtos for each row execute function validar_estoque_positivo();
create trigger update_produtos_updated_at before
update
    on
    public.produtos for each row execute function update_updated_at_column();

-- Permissions

ALTER TABLE public.produtos OWNER TO postgres;
GRANT ALL ON TABLE public.produtos TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produtos TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produtos TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produtos TO service_role;


-- public.usuarios_modulos definição

-- Drop table

-- DROP TABLE public.usuarios_modulos;

CREATE TABLE public.usuarios_modulos ( id uuid DEFAULT gen_random_uuid() NOT NULL, usuario_id uuid NOT NULL, modulo_id uuid NOT NULL, pode_acessar bool DEFAULT true NULL, pode_criar bool DEFAULT false NULL, pode_editar bool DEFAULT false NULL, pode_deletar bool DEFAULT false NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT usuarios_modulos_pkey PRIMARY KEY (id), CONSTRAINT usuarios_modulos_usuario_id_modulo_id_key UNIQUE (usuario_id, modulo_id), CONSTRAINT usuarios_modulos_modulo_id_fkey FOREIGN KEY (modulo_id) REFERENCES public.modulos(id) ON DELETE CASCADE);
CREATE INDEX idx_usuarios_modulos_modulo ON public.usuarios_modulos USING btree (modulo_id);
CREATE INDEX idx_usuarios_modulos_usuario ON public.usuarios_modulos USING btree (usuario_id);
CREATE INDEX idx_usuarios_modulos_usuario_modulo ON public.usuarios_modulos USING btree (usuario_id, modulo_id);

-- Permissions

ALTER TABLE public.usuarios_modulos OWNER TO postgres;
GRANT ALL ON TABLE public.usuarios_modulos TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.usuarios_modulos TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.usuarios_modulos TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.usuarios_modulos TO service_role;


-- public.vendas definição

-- Drop table

-- DROP TABLE public.vendas;

CREATE TABLE public.vendas ( id uuid DEFAULT uuid_generate_v4() NOT NULL, numero_nf varchar(20) NULL, caixa_id uuid NOT NULL, movimentacao_caixa_id uuid NOT NULL, operador_id uuid NOT NULL, cliente_id uuid NULL, subtotal numeric(12, 2) DEFAULT 0.00 NOT NULL, desconto numeric(12, 2) DEFAULT 0.00 NULL, desconto_percentual numeric(5, 2) DEFAULT 0.00 NULL, acrescimo numeric(12, 2) DEFAULT 0.00 NULL, impostos numeric(12, 2) DEFAULT 0.00 NULL, total numeric(12, 2) DEFAULT 0.00 NOT NULL, forma_pagamento public."pagamento_forma" NOT NULL, valor_pago numeric(12, 2) NOT NULL, valor_troco numeric(12, 2) DEFAULT 0.00 NULL, status_venda public."venda_status" DEFAULT 'FINALIZADA'::venda_status NULL, status_fiscal public."documento_fiscal_status" DEFAULT 'SEM_DOCUMENTO_FISCAL'::documento_fiscal_status NULL, numero_nfce varchar(50) NULL, numero_nfe varchar(50) NULL, chave_acesso_nfce varchar(50) NULL, chave_acesso_nfe varchar(50) NULL, protocolo_nfce varchar(50) NULL, protocolo_nfe varchar(50) NULL, xml_nfce text NULL, xml_nfe text NULL, mensagem_erro_fiscal text NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, numero varchar(20) NULL, status varchar(20) DEFAULT 'FINALIZADA'::character varying NULL, data_venda timestamptz DEFAULT now() NULL, sessao_id uuid NULL, vendedor_id uuid NULL, desconto_valor numeric(12, 2) DEFAULT 0 NULL, troco numeric(12, 2) DEFAULT 0 NULL, nfce_id varchar NULL, CONSTRAINT vendas_numero_nf_key UNIQUE (numero_nf), CONSTRAINT vendas_pkey PRIMARY KEY (id), CONSTRAINT vendas_caixa_id_fkey FOREIGN KEY (caixa_id) REFERENCES public.caixas(id), CONSTRAINT vendas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id), CONSTRAINT vendas_movimentacao_caixa_id_fkey FOREIGN KEY (movimentacao_caixa_id) REFERENCES public.caixa_sessoes(id), CONSTRAINT vendas_operador_id_fkey FOREIGN KEY (operador_id) REFERENCES public.users(id));
CREATE INDEX idx_vendas_caixa ON public.vendas USING btree (caixa_id);
CREATE INDEX idx_vendas_cliente ON public.vendas USING btree (cliente_id);
CREATE INDEX idx_vendas_created ON public.vendas USING btree (created_at DESC);
CREATE INDEX idx_vendas_data ON public.vendas USING btree (data_venda);
CREATE INDEX idx_vendas_fiscal_status ON public.vendas USING btree (status_fiscal);
CREATE INDEX idx_vendas_nfce_id ON public.vendas USING btree (nfce_id);
CREATE INDEX idx_vendas_numero ON public.vendas USING btree (numero);
CREATE INDEX idx_vendas_operador ON public.vendas USING btree (operador_id);
CREATE INDEX idx_vendas_sessao ON public.vendas USING btree (sessao_id);
CREATE INDEX idx_vendas_troco ON public.vendas USING btree (troco);

-- Table Triggers

create trigger update_vendas_estoque after
update
    on
    public.vendas for each row execute function atualizar_estoque_venda();

-- Permissions

ALTER TABLE public.vendas OWNER TO postgres;
GRANT ALL ON TABLE public.vendas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas TO service_role;


-- public.caixa_movimentacoes definição

-- Drop table

-- DROP TABLE public.caixa_movimentacoes;

CREATE TABLE public.caixa_movimentacoes ( id uuid NOT NULL, sessao_id uuid NOT NULL, tipo varchar(20) NOT NULL, valor numeric(12, 2) NOT NULL, motivo text NULL, responsavel_id uuid NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT caixa_movimentacoes_pkey PRIMARY KEY (id), CONSTRAINT caixa_movimentacoes_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['SANGRIA'::character varying, 'SUPRIMENTO'::character varying])::text[]))), CONSTRAINT caixa_movimentacoes_sessao_id_fkey FOREIGN KEY (sessao_id) REFERENCES public.caixa_sessoes(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE public.caixa_movimentacoes OWNER TO postgres;
GRANT ALL ON TABLE public.caixa_movimentacoes TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_movimentacoes TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_movimentacoes TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.caixa_movimentacoes TO service_role;


-- public.comandas definição

-- Drop table

-- DROP TABLE public.comandas;

CREATE TABLE public.comandas ( id uuid DEFAULT uuid_generate_v4() NOT NULL, numero_comanda varchar(20) NOT NULL, numero_mesa varchar(10) NULL, tipo varchar(20) DEFAULT 'mesa'::character varying NULL, cliente_id uuid NULL, cliente_nome varchar(255) NULL, status varchar(20) DEFAULT 'aberta'::character varying NULL, data_abertura timestamp DEFAULT now() NULL, data_fechamento timestamp NULL, usuario_abertura_id uuid NULL, usuario_fechamento_id uuid NULL, subtotal numeric(10, 2) DEFAULT 0 NULL, desconto numeric(10, 2) DEFAULT 0 NULL, acrescimo numeric(10, 2) DEFAULT 0 NULL, valor_total numeric(10, 2) DEFAULT 0 NULL, observacoes text NULL, venda_id uuid NULL, created_at timestamp DEFAULT now() NULL, updated_at timestamp DEFAULT now() NULL, CONSTRAINT comandas_numero_comanda_key UNIQUE (numero_comanda), CONSTRAINT comandas_pkey PRIMARY KEY (id), CONSTRAINT comandas_status_check CHECK (((status)::text = ANY ((ARRAY['aberta'::character varying, 'fechada'::character varying, 'cancelada'::character varying])::text[]))), CONSTRAINT comandas_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['mesa'::character varying, 'balcao'::character varying, 'delivery'::character varying])::text[]))), CONSTRAINT comandas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id), CONSTRAINT comandas_usuario_abertura_id_fkey FOREIGN KEY (usuario_abertura_id) REFERENCES public.users(id), CONSTRAINT comandas_usuario_fechamento_id_fkey FOREIGN KEY (usuario_fechamento_id) REFERENCES public.users(id), CONSTRAINT comandas_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id));
CREATE INDEX idx_comandas_data_abertura ON public.comandas USING btree (data_abertura);
CREATE INDEX idx_comandas_mesa ON public.comandas USING btree (numero_mesa);
CREATE INDEX idx_comandas_numero ON public.comandas USING btree (numero_comanda);
CREATE INDEX idx_comandas_status ON public.comandas USING btree (status);
CREATE UNIQUE INDEX idx_comandas_venda_id_unica ON public.comandas USING btree (venda_id) WHERE (venda_id IS NOT NULL);
COMMENT ON INDEX public.idx_comandas_venda_id_unica IS 'Garante que cada venda está ligada a no máximo uma comanda. O índice ignora linhas com venda_id NULL.';
COMMENT ON TABLE public.comandas IS 'Comandas/vendas em aberto para consumo no local';

-- Column comments

COMMENT ON COLUMN public.comandas.numero_comanda IS 'Identificador único da comanda (Mesa 1, Comanda 001, etc)';
COMMENT ON COLUMN public.comandas.tipo IS 'Tipo de atendimento: mesa, balcao ou delivery';
COMMENT ON COLUMN public.comandas.status IS 'Status da comanda: aberta, fechada ou cancelada';

-- Permissions

ALTER TABLE public.comandas OWNER TO postgres;
GRANT ALL ON TABLE public.comandas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.comandas TO anon;
GRANT ALL ON TABLE public.comandas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.comandas TO service_role;


-- public.contas_pagar definição

-- Drop table

-- DROP TABLE public.contas_pagar;

CREATE TABLE public.contas_pagar ( id uuid NOT NULL, numero_documento varchar(50) NULL, descricao varchar(255) NOT NULL, fornecedor_id uuid NULL, pedido_compra_id uuid NULL, valor_original numeric(12, 2) NOT NULL, valor_desconto numeric(12, 2) DEFAULT 0 NULL, valor_juros numeric(12, 2) DEFAULT 0 NULL, valor_multa numeric(12, 2) DEFAULT 0 NULL, valor_pago numeric(12, 2) DEFAULT 0 NULL, valor_total numeric(12, 2) GENERATED ALWAYS AS ((valor_original - valor_desconto + valor_juros + valor_multa)) STORED NULL, data_emissao date DEFAULT CURRENT_DATE NULL, data_vencimento date NOT NULL, data_pagamento date NULL, forma_pagamento varchar(30) NULL, conta_bancaria varchar(100) NULL, status varchar(20) DEFAULT 'PENDENTE'::character varying NULL, categoria varchar(50) DEFAULT 'FORNECEDOR'::character varying NULL, centro_custo varchar(50) NULL, parcela_atual int4 DEFAULT 1 NULL, total_parcelas int4 DEFAULT 1 NULL, observacoes text NULL, usuario_id uuid NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, CONSTRAINT contas_pagar_pkey PRIMARY KEY (id), CONSTRAINT contas_pagar_status_check CHECK (((status)::text = ANY ((ARRAY['PENDENTE'::character varying, 'PAGO'::character varying, 'PAGO_PARCIAL'::character varying, 'VENCIDO'::character varying, 'CANCELADO'::character varying])::text[]))), CONSTRAINT contas_pagar_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id), CONSTRAINT contas_pagar_pedido_compra_id_fkey FOREIGN KEY (pedido_compra_id) REFERENCES public.pedidos_compra(id));
CREATE INDEX idx_contas_pagar_categoria ON public.contas_pagar USING btree (categoria);
CREATE INDEX idx_contas_pagar_fornecedor ON public.contas_pagar USING btree (fornecedor_id);
CREATE INDEX idx_contas_pagar_status ON public.contas_pagar USING btree (status);
CREATE INDEX idx_contas_pagar_vencimento ON public.contas_pagar USING btree (data_vencimento);

-- Permissions

ALTER TABLE public.contas_pagar OWNER TO postgres;
GRANT ALL ON TABLE public.contas_pagar TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_pagar TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_pagar TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_pagar TO service_role;


-- public.contas_receber definição

-- Drop table

-- DROP TABLE public.contas_receber;

CREATE TABLE public.contas_receber ( id uuid DEFAULT uuid_generate_v4() NOT NULL, venda_id uuid NULL, cliente_id uuid NOT NULL, valor_original numeric(12, 2) NOT NULL, valor_pago numeric(12, 2) DEFAULT 0.00 NULL, valor_pendente numeric(12, 2) NOT NULL, data_vencimento date NOT NULL, data_pagamento date NULL, juros numeric(12, 2) DEFAULT 0.00 NULL, multa numeric(12, 2) DEFAULT 0.00 NULL, desconto numeric(12, 2) DEFAULT 0.00 NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, valor_recebido numeric(12, 2) DEFAULT 0 NULL, status varchar(20) DEFAULT 'PENDENTE'::character varying NULL, valor_desconto numeric(12, 2) DEFAULT 0 NULL, valor_juros numeric(12, 2) DEFAULT 0 NULL, valor_multa numeric(12, 2) DEFAULT 0 NULL, data_recebimento date NULL, numero_documento varchar(50) NULL, descricao varchar(255) NULL, data_emissao date DEFAULT CURRENT_DATE NULL, forma_recebimento varchar(30) NULL, conta_bancaria varchar(100) NULL, categoria varchar(50) DEFAULT 'VENDA'::character varying NULL, parcela_atual int4 DEFAULT 1 NULL, total_parcelas int4 DEFAULT 1 NULL, usuario_id uuid NULL, CONSTRAINT contas_receber_pkey PRIMARY KEY (id), CONSTRAINT contas_receber_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id), CONSTRAINT contas_receber_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id));
CREATE INDEX idx_contas_receber_cliente ON public.contas_receber USING btree (cliente_id);
CREATE INDEX idx_contas_receber_status ON public.contas_receber USING btree (status);
CREATE INDEX idx_contas_receber_vencimento ON public.contas_receber USING btree (data_vencimento);

-- Table Triggers

create trigger update_contas_saldo_cliente after
insert
    or
update
    on
    public.contas_receber for each row execute function atualizar_saldo_cliente();

-- Permissions

ALTER TABLE public.contas_receber OWNER TO postgres;
GRANT ALL ON TABLE public.contas_receber TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_receber TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_receber TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.contas_receber TO service_role;


-- public.documentos_fiscais definição

-- Drop table

-- DROP TABLE public.documentos_fiscais;

CREATE TABLE public.documentos_fiscais ( id uuid DEFAULT uuid_generate_v4() NOT NULL, venda_id uuid NOT NULL, tipo_documento varchar(20) NOT NULL, numero_documento varchar(50) NULL, serie int4 NULL, chave_acesso varchar(50) NULL, protocolo_autorizacao varchar(50) NULL, status_sefaz varchar(50) NULL, mensagem_sefaz text NULL, xml_nota text NULL, xml_retorno text NULL, valor_total numeric(12, 2) NULL, natureza_operacao varchar(100) NULL, data_emissao timestamptz NULL, data_autorizacao timestamptz NULL, tentativas_emissao int4 DEFAULT 0 NULL, ultima_tentativa timestamptz NULL, proximo_retry timestamptz NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, api_provider varchar DEFAULT 'focus_nfe'::character varying NULL, nfce_id varchar(100) NULL, CONSTRAINT documentos_fiscais_api_provider_check CHECK (((api_provider)::text = ANY ((ARRAY['focus_nfe'::character varying, 'nuvem_fiscal'::character varying])::text[]))), CONSTRAINT documentos_fiscais_pkey PRIMARY KEY (id), CONSTRAINT documentos_fiscais_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id) ON DELETE CASCADE);
CREATE INDEX idx_docs_fiscais_status ON public.documentos_fiscais USING btree (status_sefaz);
CREATE INDEX idx_docs_fiscais_venda ON public.documentos_fiscais USING btree (venda_id);
CREATE INDEX idx_documentos_fiscais_api_provider ON public.documentos_fiscais USING btree (api_provider);
CREATE INDEX idx_documentos_fiscais_nfce_id ON public.documentos_fiscais USING btree (nfce_id) WHERE (nfce_id IS NOT NULL);

-- Column comments

COMMENT ON COLUMN public.documentos_fiscais.api_provider IS 'Provedor da API fiscal: focus_nfe ou nuvem_fiscal';

-- Permissions

ALTER TABLE public.documentos_fiscais OWNER TO postgres;
GRANT ALL ON TABLE public.documentos_fiscais TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.documentos_fiscais TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.documentos_fiscais TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.documentos_fiscais TO service_role;


-- public.movimentacoes_financeiras definição

-- Drop table

-- DROP TABLE public.movimentacoes_financeiras;

CREATE TABLE public.movimentacoes_financeiras ( id uuid NOT NULL, tipo varchar(20) NOT NULL, conta_pagar_id uuid NULL, conta_receber_id uuid NULL, valor numeric(12, 2) NOT NULL, data_movimento date DEFAULT CURRENT_DATE NULL, forma varchar(30) NULL, conta_bancaria varchar(100) NULL, comprovante varchar(255) NULL, observacoes text NULL, usuario_id uuid NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT movimentacoes_financeiras_pkey PRIMARY KEY (id), CONSTRAINT movimentacoes_financeiras_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['PAGAMENTO'::character varying, 'RECEBIMENTO'::character varying])::text[]))), CONSTRAINT movimentacoes_financeiras_conta_pagar_id_fkey FOREIGN KEY (conta_pagar_id) REFERENCES public.contas_pagar(id));

-- Permissions

ALTER TABLE public.movimentacoes_financeiras OWNER TO postgres;
GRANT ALL ON TABLE public.movimentacoes_financeiras TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_financeiras TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_financeiras TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.movimentacoes_financeiras TO service_role;


-- public.pagamentos_venda definição

-- Drop table

-- DROP TABLE public.pagamentos_venda;

CREATE TABLE public.pagamentos_venda ( id uuid DEFAULT uuid_generate_v4() NOT NULL, venda_id uuid NOT NULL, forma public."pagamento_forma" NOT NULL, valor numeric(12, 2) NOT NULL, numero_parcela int4 DEFAULT 1 NULL, total_parcelas int4 DEFAULT 1 NULL, data_vencimento date NULL, status_pagamento varchar(20) DEFAULT 'RECEBIDO'::character varying NULL, observacoes text NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT pagamentos_venda_pkey PRIMARY KEY (id), CONSTRAINT pagamentos_venda_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE public.pagamentos_venda OWNER TO postgres;
GRANT ALL ON TABLE public.pagamentos_venda TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pagamentos_venda TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pagamentos_venda TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pagamentos_venda TO service_role;


-- public.pedido_compra_itens definição

-- Drop table

-- DROP TABLE public.pedido_compra_itens;

CREATE TABLE public.pedido_compra_itens ( id uuid NOT NULL, pedido_id uuid NOT NULL, produto_id uuid NOT NULL, quantidade numeric(12, 3) NOT NULL, quantidade_recebida numeric(12, 3) DEFAULT 0 NULL, preco_unitario numeric(12, 2) NOT NULL, subtotal numeric(12, 2) NOT NULL, numero_lote varchar(50) NULL, data_validade date NULL, created_at timestamptz DEFAULT now() NULL, nota_saida_emitida bool DEFAULT false NULL, nota_saida_id uuid NULL, nota_saida_numero varchar(20) NULL, preco_venda_nfe numeric(12, 2) NULL, CONSTRAINT pedido_compra_itens_pkey PRIMARY KEY (id), CONSTRAINT pedido_compra_itens_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos_compra(id) ON DELETE CASCADE, CONSTRAINT pedido_compra_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id) ON DELETE RESTRICT);
CREATE INDEX idx_pedido_compra_itens_nota_saida ON public.pedido_compra_itens USING btree (nota_saida_emitida, pedido_id);
CREATE INDEX idx_pedido_compra_itens_produto_id ON public.pedido_compra_itens USING btree (produto_id);

-- Column comments

COMMENT ON COLUMN public.pedido_compra_itens.nota_saida_emitida IS 'Indica se já foi emitida nota de saída para esta entrada';
COMMENT ON COLUMN public.pedido_compra_itens.nota_saida_id IS 'ID da venda/NFC-e emitida como saída';
COMMENT ON COLUMN public.pedido_compra_itens.nota_saida_numero IS 'Número da nota de saída emitida';
COMMENT ON COLUMN public.pedido_compra_itens.preco_venda_nfe IS 'Preço de venda customizado para emissão na NFC-e desta entrada';

-- Permissions

ALTER TABLE public.pedido_compra_itens OWNER TO postgres;
GRANT ALL ON TABLE public.pedido_compra_itens TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedido_compra_itens TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedido_compra_itens TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.pedido_compra_itens TO service_role;


-- public.produto_lotes definição

-- Drop table

-- DROP TABLE public.produto_lotes;

CREATE TABLE public.produto_lotes ( id uuid DEFAULT uuid_generate_v4() NOT NULL, produto_id uuid NOT NULL, numero_lote varchar(50) NOT NULL, data_fabricacao date NULL, data_vencimento date NULL, quantidade numeric(10, 2) DEFAULT 0.00 NOT NULL, localizacao text NULL, ativo bool DEFAULT true NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, data_validade date NULL, quantidade_inicial numeric(12, 3) DEFAULT 0 NULL, quantidade_atual numeric(12, 3) DEFAULT 0 NULL, preco_custo numeric(12, 2) DEFAULT 0 NULL, fornecedor_id uuid NULL, nota_fiscal varchar(50) NULL, observacoes text NULL, status varchar(20) DEFAULT 'ATIVO'::character varying NULL, CONSTRAINT produto_lotes_pkey PRIMARY KEY (id), CONSTRAINT produto_lotes_produto_id_numero_lote_key UNIQUE (produto_id, numero_lote), CONSTRAINT produto_lotes_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id) ON DELETE CASCADE);
CREATE INDEX idx_lotes_produto ON public.produto_lotes USING btree (produto_id);
CREATE INDEX idx_lotes_status ON public.produto_lotes USING btree (status);
CREATE INDEX idx_lotes_validade ON public.produto_lotes USING btree (data_validade);

-- Permissions

ALTER TABLE public.produto_lotes OWNER TO postgres;
GRANT ALL ON TABLE public.produto_lotes TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produto_lotes TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produto_lotes TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.produto_lotes TO service_role;


-- public.vendas_itens definição

-- Drop table

-- DROP TABLE public.vendas_itens;

CREATE TABLE public.vendas_itens ( id uuid DEFAULT uuid_generate_v4() NOT NULL, venda_id uuid NOT NULL, produto_id uuid NOT NULL, lote_id uuid NULL, quantidade numeric(10, 2) NOT NULL, "unidade_medida" public."unidade_medida" NOT NULL, preco_unitario numeric(12, 2) NOT NULL, subtotal numeric(12, 2) NOT NULL, desconto numeric(12, 2) DEFAULT 0.00 NULL, desconto_percentual numeric(5, 2) DEFAULT 0.00 NULL, acrescimo numeric(12, 2) DEFAULT 0.00 NULL, total numeric(12, 2) NOT NULL, created_at timestamptz DEFAULT now() NULL, preco_custo numeric(12, 2) NULL, CONSTRAINT vendas_itens_pkey PRIMARY KEY (id), CONSTRAINT vendas_itens_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES public.produto_lotes(id), CONSTRAINT vendas_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id), CONSTRAINT vendas_itens_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id) ON DELETE CASCADE);
CREATE INDEX idx_vendas_itens_lote ON public.vendas_itens USING btree (lote_id);
CREATE INDEX idx_vendas_itens_produto ON public.vendas_itens USING btree (produto_id);
CREATE INDEX idx_vendas_itens_venda ON public.vendas_itens USING btree (venda_id);

-- Column comments

COMMENT ON COLUMN public.vendas_itens.preco_custo IS 'Preço de custo no momento da venda - usado para análise de lucro';

-- Table Triggers

create trigger trg_before_insert_venda_item_custo before
insert
    on
    public.vendas_itens for each row execute function trg_venda_item_set_preco_custo();

-- Permissions

ALTER TABLE public.vendas_itens OWNER TO postgres;
GRANT ALL ON TABLE public.vendas_itens TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas_itens TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas_itens TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vendas_itens TO service_role;


-- public.comanda_itens definição

-- Drop table

-- DROP TABLE public.comanda_itens;

CREATE TABLE public.comanda_itens ( id uuid DEFAULT uuid_generate_v4() NOT NULL, comanda_id uuid NOT NULL, produto_id uuid NOT NULL, nome_produto varchar(255) NOT NULL, quantidade numeric(10, 3) DEFAULT 1 NOT NULL, preco_unitario numeric(10, 2) NOT NULL, subtotal numeric(10, 2) NOT NULL, desconto numeric(10, 2) DEFAULT 0 NULL, status varchar(20) DEFAULT 'pendente'::character varying NULL, observacoes text NULL, usuario_id uuid NULL, created_at timestamp DEFAULT now() NULL, updated_at timestamp DEFAULT now() NULL, CONSTRAINT comanda_itens_pkey PRIMARY KEY (id), CONSTRAINT comanda_itens_status_check CHECK (((status)::text = ANY ((ARRAY['pendente'::character varying, 'preparando'::character varying, 'entregue'::character varying, 'cancelado'::character varying])::text[]))), CONSTRAINT comanda_itens_comanda_id_fkey FOREIGN KEY (comanda_id) REFERENCES public.comandas(id) ON DELETE CASCADE, CONSTRAINT comanda_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id), CONSTRAINT comanda_itens_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id));
CREATE INDEX idx_comanda_itens_comanda ON public.comanda_itens USING btree (comanda_id);
CREATE INDEX idx_comanda_itens_produto ON public.comanda_itens USING btree (produto_id);
CREATE INDEX idx_comanda_itens_status ON public.comanda_itens USING btree (status);
COMMENT ON TABLE public.comanda_itens IS 'Itens adicionados às comandas abertas';

-- Column comments

COMMENT ON COLUMN public.comanda_itens.status IS 'Status do item: pendente, preparando, entregue, cancelado';

-- Table Triggers

create trigger trigger_atualizar_totais_comanda_delete after
delete
    on
    public.comanda_itens for each row execute function atualizar_totais_comanda();
create trigger trigger_atualizar_totais_comanda_insert after
insert
    on
    public.comanda_itens for each row execute function atualizar_totais_comanda();
create trigger trigger_atualizar_totais_comanda_update after
update
    on
    public.comanda_itens for each row execute function atualizar_totais_comanda();

-- Permissions

ALTER TABLE public.comanda_itens OWNER TO postgres;
GRANT ALL ON TABLE public.comanda_itens TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.comanda_itens TO anon;
GRANT ALL ON TABLE public.comanda_itens TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.comanda_itens TO service_role;


-- public.estoque_movimentacoes definição

-- Drop table

-- DROP TABLE public.estoque_movimentacoes;

CREATE TABLE public.estoque_movimentacoes ( id uuid DEFAULT uuid_generate_v4() NOT NULL, produto_id uuid NOT NULL, lote_id uuid NULL, tipo_movimento varchar(20) NOT NULL, quantidade numeric(10, 2) NOT NULL, "unidade_medida" public."unidade_medida" NOT NULL, preco_unitario numeric(12, 2) NULL, motivo text NULL, referencia_id uuid NULL, referencia_tipo varchar(50) NULL, usuario_id uuid NOT NULL, created_at timestamptz DEFAULT now() NULL, CONSTRAINT estoque_movimentacoes_pkey PRIMARY KEY (id), CONSTRAINT estoque_movimentacoes_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES public.produto_lotes(id), CONSTRAINT estoque_movimentacoes_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id), CONSTRAINT estoque_movimentacoes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id));
CREATE INDEX idx_estoque_mov_created ON public.estoque_movimentacoes USING btree (created_at DESC);
CREATE INDEX idx_estoque_mov_data ON public.estoque_movimentacoes USING btree (created_at DESC);
CREATE INDEX idx_estoque_mov_produto ON public.estoque_movimentacoes USING btree (produto_id);
CREATE INDEX idx_estoque_mov_referencia ON public.estoque_movimentacoes USING btree (referencia_id, referencia_tipo);
CREATE INDEX idx_estoque_mov_tipo ON public.estoque_movimentacoes USING btree (tipo_movimento);
COMMENT ON TABLE public.estoque_movimentacoes IS 'Registro de TODAS as movimentações de estoque - entrada, saída, ajustes';

-- Permissions

ALTER TABLE public.estoque_movimentacoes OWNER TO postgres;
GRANT ALL ON TABLE public.estoque_movimentacoes TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_movimentacoes TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_movimentacoes TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.estoque_movimentacoes TO service_role;


-- public.v_contas_pagar_vencidas fonte

CREATE OR REPLACE VIEW public.v_contas_pagar_vencidas
AS SELECT cp.id,
    cp.numero_documento,
    cp.descricao,
    cp.fornecedor_id,
    cp.pedido_compra_id,
    cp.valor_original,
    cp.valor_desconto,
    cp.valor_juros,
    cp.valor_multa,
    cp.valor_pago,
    cp.valor_total,
    cp.data_emissao,
    cp.data_vencimento,
    cp.data_pagamento,
    cp.forma_pagamento,
    cp.conta_bancaria,
    cp.status,
    cp.categoria,
    cp.centro_custo,
    cp.parcela_atual,
    cp.total_parcelas,
    cp.observacoes,
    cp.usuario_id,
    cp.created_at,
    cp.updated_at,
    f.nome AS fornecedor_nome,
    f.razao_social AS fornecedor_razao_social,
    f.cnpj AS fornecedor_cnpj,
    CURRENT_DATE - cp.data_vencimento AS dias_atraso
   FROM contas_pagar cp
     LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id
  WHERE (cp.status::text = ANY (ARRAY['PENDENTE'::character varying, 'PAGO_PARCIAL'::character varying]::text[])) AND cp.data_vencimento < CURRENT_DATE
  ORDER BY cp.data_vencimento;

-- Permissions

ALTER TABLE public.v_contas_pagar_vencidas OWNER TO postgres;
GRANT ALL ON TABLE public.v_contas_pagar_vencidas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_pagar_vencidas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_pagar_vencidas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_pagar_vencidas TO service_role;


-- public.v_contas_receber_vencidas fonte

CREATE OR REPLACE VIEW public.v_contas_receber_vencidas
AS SELECT cr.id,
    cr.venda_id,
    cr.cliente_id,
    cr.valor_original,
    cr.valor_pago,
    cr.valor_pendente,
    cr.data_vencimento,
    cr.data_pagamento,
    cr.juros,
    cr.multa,
    cr.desconto,
    cr.observacoes,
    cr.created_at,
    cr.updated_at,
    cr.valor_recebido,
    cr.status,
    cr.valor_desconto,
    cr.valor_juros,
    cr.valor_multa,
    cr.data_recebimento,
    cr.numero_documento,
    cr.descricao,
    cr.data_emissao,
    cr.forma_recebimento,
    cr.conta_bancaria,
    cr.categoria,
    cr.parcela_atual,
    cr.total_parcelas,
    cr.usuario_id,
    c.nome AS cliente_nome,
    c.cpf_cnpj AS cliente_documento,
    c.telefone AS cliente_telefone,
    CURRENT_DATE - cr.data_vencimento AS dias_atraso
   FROM contas_receber cr
     LEFT JOIN clientes c ON c.id = cr.cliente_id
  WHERE (cr.status::text = ANY (ARRAY['PENDENTE'::character varying, 'PAGO_PARCIAL'::character varying]::text[])) AND cr.data_vencimento < CURRENT_DATE
  ORDER BY cr.data_vencimento;

-- Permissions

ALTER TABLE public.v_contas_receber_vencidas OWNER TO postgres;
GRANT ALL ON TABLE public.v_contas_receber_vencidas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_receber_vencidas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_receber_vencidas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_contas_receber_vencidas TO service_role;


-- public.v_vendas_do_dia fonte

CREATE OR REPLACE VIEW public.v_vendas_do_dia
AS SELECT CURRENT_DATE AS data_venda,
    count(DISTINCT id) AS total_vendas,
    sum(total) AS valor_total,
    count(DISTINCT cliente_id) AS clientes_unicos,
    sum(
        CASE
            WHEN status_venda = 'FINALIZADA'::venda_status THEN total
            ELSE 0::numeric
        END) AS valor_vendas_finalizadas
   FROM vendas
  WHERE date(created_at) = CURRENT_DATE;

-- Permissions

ALTER TABLE public.v_vendas_do_dia OWNER TO postgres;
GRANT ALL ON TABLE public.v_vendas_do_dia TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_vendas_do_dia TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_vendas_do_dia TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.v_vendas_do_dia TO service_role;


-- public.vw_analise_vendas fonte

CREATE OR REPLACE VIEW public.vw_analise_vendas
AS SELECT v.id AS venda_id,
    v.numero,
    v.created_at AS data_venda,
    v.total AS total_venda,
    c.nome AS cliente_nome,
    u.nome_completo AS operador_nome,
    COALESCE(sum(vi.quantidade * vi.preco_custo), 0::numeric) AS custo_total,
    v.total - COALESCE(sum(vi.quantidade * vi.preco_custo), 0::numeric) AS lucro_bruto,
        CASE
            WHEN COALESCE(sum(vi.quantidade * vi.preco_custo), 0::numeric) > 0::numeric THEN (v.total - COALESCE(sum(vi.quantidade * vi.preco_custo), 0::numeric)) / COALESCE(sum(vi.quantidade * vi.preco_custo), 1::numeric) * 100::numeric
            ELSE 0::numeric
        END AS margem_lucro_percentual
   FROM vendas v
     LEFT JOIN venda_itens vi ON vi.venda_id = v.id
     LEFT JOIN clientes c ON c.id = v.cliente_id
     LEFT JOIN users u ON u.id = v.operador_id
  WHERE v.status::text = 'FINALIZADA'::text OR v.status_venda = 'FINALIZADA'::venda_status
  GROUP BY v.id, v.numero, v.created_at, v.total, c.nome, u.nome_completo;

-- Permissions

ALTER TABLE public.vw_analise_vendas OWNER TO postgres;
GRANT ALL ON TABLE public.vw_analise_vendas TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_analise_vendas TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_analise_vendas TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_analise_vendas TO service_role;


-- public.vw_posicao_estoque fonte

CREATE OR REPLACE VIEW public.vw_posicao_estoque
AS SELECT p.id,
    p.codigo,
    p.codigo_barras,
    p.nome,
    p.estoque_atual,
    p.estoque_minimo,
    p.estoque_maximo,
    p.preco_custo,
    p.preco_venda,
    p.unidade,
    c.nome AS categoria,
    m.nome AS marca,
        CASE
            WHEN p.estoque_atual <= 0::numeric THEN 'SEM_ESTOQUE'::text
            WHEN p.estoque_atual <= p.estoque_minimo THEN 'ESTOQUE_BAIXO'::text
            WHEN p.estoque_atual >= p.estoque_maximo THEN 'ESTOQUE_ALTO'::text
            ELSE 'ESTOQUE_NORMAL'::text
        END AS status_estoque,
    p.estoque_atual * p.preco_custo AS valor_estoque,
    p.created_at,
    p.updated_at
   FROM produtos p
     LEFT JOIN categorias c ON c.id = p.categoria_id
     LEFT JOIN marcas m ON m.id = p.marca_id
  WHERE p.ativo = true
  ORDER BY p.nome;

-- Permissions

ALTER TABLE public.vw_posicao_estoque OWNER TO postgres;
GRANT ALL ON TABLE public.vw_posicao_estoque TO postgres;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_posicao_estoque TO anon;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_posicao_estoque TO authenticated;
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE public.vw_posicao_estoque TO service_role;



-- DROP FUNCTION public.armor(bytea);

CREATE OR REPLACE FUNCTION public.armor(bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_armor$function$
;

-- Permissions

ALTER FUNCTION public.armor(bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.armor(bytea) TO supabase_admin;

-- DROP FUNCTION public.armor(bytea, _text, _text);

CREATE OR REPLACE FUNCTION public.armor(bytea, text[], text[])
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_armor$function$
;

-- Permissions

ALTER FUNCTION public.armor(bytea, _text, _text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.armor(bytea, _text, _text) TO supabase_admin;

-- DROP FUNCTION public.atualizar_estoque_venda();

CREATE OR REPLACE FUNCTION public.atualizar_estoque_venda()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Reduzir estoque ao finalizar venda
    IF NEW.status_venda = 'FINALIZADA' AND OLD.status_venda != 'FINALIZADA' THEN
        UPDATE produtos SET estoque_atual = estoque_atual - (
            SELECT COALESCE(SUM(quantidade), 0) 
            FROM vendas_itens 
            WHERE venda_id = NEW.id
        )
        WHERE id IN (SELECT produto_id FROM vendas_itens WHERE venda_id = NEW.id);
    END IF;
    
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.atualizar_estoque_venda() OWNER TO postgres;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda() TO public;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda() TO postgres;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda() TO anon;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda() TO service_role;

-- DROP FUNCTION public.atualizar_estoque_venda_com_validacao(uuid);

CREATE OR REPLACE FUNCTION public.atualizar_estoque_venda_com_validacao(p_venda_id uuid)
 RETURNS TABLE(sucesso boolean, mensagem text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_item RECORD;
    v_estoque_disponivel NUMERIC;
BEGIN
    -- Loop em cada item da venda
    FOR v_item IN 
        SELECT produto_id, quantidade FROM vendas_itens WHERE venda_id = p_venda_id
    LOOP
        -- Verificar estoque disponível
        SELECT estoque_atual INTO v_estoque_disponivel
        FROM produtos
        WHERE id = v_item.produto_id;

        IF v_estoque_disponivel < v_item.quantidade THEN
            RETURN QUERY SELECT false, 'Estoque insuficiente para produto: ' || v_item.produto_id::text;
            RETURN;
        END IF;

        -- Atualizar estoque
        UPDATE produtos
        SET estoque_atual = estoque_atual - v_item.quantidade
        WHERE id = v_item.produto_id;

        -- Registrar movimento
        INSERT INTO estoque_movimentacoes (
            produto_id,
            tipo_movimento,
            quantidade,
            unidade_medida,
            motivo,
            referencia_id,
            referencia_tipo,
            usuario_id
        ) VALUES (
            v_item.produto_id,
            'SAIDA',
            v_item.quantidade,
            'UN',
            'Venda PDV',
            p_venda_id,
            'VENDA',
            auth.uid()
        );
    END LOOP;

    RETURN QUERY SELECT true, 'Estoque atualizado com sucesso';
END;
$function$
;

-- Permissions

ALTER FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) OWNER TO postgres;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) TO public;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) TO postgres;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) TO anon;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_estoque_venda_com_validacao(uuid) TO service_role;

-- DROP FUNCTION public.atualizar_quantidade_lotes();

CREATE OR REPLACE FUNCTION public.atualizar_quantidade_lotes()
 RETURNS TABLE(lote_id uuid, numero_lote character varying, quantidade_atual numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    WITH lote_saidas AS (
        SELECT 
            vi.lote_id,
            pl.numero_lote,
            SUM(vi.quantidade) AS quantidade_saida
        FROM public.vendas_itens vi
        JOIN public.vendas v ON vi.venda_id = v.id
        JOIN public.produto_lotes pl ON vi.lote_id = pl.id
        WHERE v.status = 'FINALIZADA'
        AND vi.lote_id IS NOT NULL
        GROUP BY vi.lote_id, pl.numero_lote
    )
    UPDATE public.produto_lotes pl
    SET quantidade_atual = GREATEST(quantidade_inicial - ls.quantidade_saida, 0)
    FROM lote_saidas ls
    WHERE pl.id = ls.lote_id
    RETURNING 
        pl.id,
        pl.numero_lote,
        pl.quantidade_atual;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.atualizar_quantidade_lotes() OWNER TO postgres;
GRANT ALL ON FUNCTION public.atualizar_quantidade_lotes() TO public;
GRANT ALL ON FUNCTION public.atualizar_quantidade_lotes() TO postgres;
GRANT ALL ON FUNCTION public.atualizar_quantidade_lotes() TO anon;
GRANT ALL ON FUNCTION public.atualizar_quantidade_lotes() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_quantidade_lotes() TO service_role;

-- DROP FUNCTION public.atualizar_saldo_cliente();

CREATE OR REPLACE FUNCTION public.atualizar_saldo_cliente()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE clientes 
    SET saldo_devedor = (
        SELECT COALESCE(SUM(valor_pendente), 0) 
        FROM contas_receber 
        WHERE cliente_id = NEW.cliente_id 
        AND status IN ('PENDENTE', 'PAGO_PARCIAL', 'VENCIDO')
    )
    WHERE id = NEW.cliente_id;
    
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.atualizar_saldo_cliente() OWNER TO postgres;
GRANT ALL ON FUNCTION public.atualizar_saldo_cliente() TO public;
GRANT ALL ON FUNCTION public.atualizar_saldo_cliente() TO postgres;
GRANT ALL ON FUNCTION public.atualizar_saldo_cliente() TO anon;
GRANT ALL ON FUNCTION public.atualizar_saldo_cliente() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_saldo_cliente() TO service_role;

-- DROP FUNCTION public.atualizar_totais_comanda();

CREATE OR REPLACE FUNCTION public.atualizar_totais_comanda()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE comandas
    SET 
        subtotal = (
            SELECT COALESCE(SUM(subtotal - desconto), 0)
            FROM comanda_itens
            WHERE comanda_id = NEW.comanda_id
            AND status != 'cancelado'
        ),
        valor_total = (
            SELECT COALESCE(SUM(subtotal - desconto), 0)
            FROM comanda_itens
            WHERE comanda_id = NEW.comanda_id
            AND status != 'cancelado'
        ) - COALESCE((SELECT desconto FROM comandas WHERE id = NEW.comanda_id), 0) 
          + COALESCE((SELECT acrescimo FROM comandas WHERE id = NEW.comanda_id), 0),
        updated_at = NOW()
    WHERE id = NEW.comanda_id;
    
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.atualizar_totais_comanda() OWNER TO postgres;
GRANT ALL ON FUNCTION public.atualizar_totais_comanda() TO public;
GRANT ALL ON FUNCTION public.atualizar_totais_comanda() TO postgres;
GRANT ALL ON FUNCTION public.atualizar_totais_comanda() TO anon;
GRANT ALL ON FUNCTION public.atualizar_totais_comanda() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_totais_comanda() TO service_role;

-- DROP FUNCTION public.buscar_produtos_disponiveis(text);

CREATE OR REPLACE FUNCTION public.buscar_produtos_disponiveis(p_busca text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, sku character varying, nome character varying, preco_venda numeric, estoque_atual numeric, disponivel boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.sku,
        p.nome,
        p.preco_venda,
        p.estoque_atual,
        (p.estoque_atual > 0) as disponivel
    FROM produtos p
    WHERE p.ativo = true
    AND (
        p_busca IS NULL 
        OR p.codigo_barras ILIKE '%' || p_busca || '%'
        OR p.sku ILIKE '%' || p_busca || '%'
        OR p.nome ILIKE '%' || p_busca || '%'
    )
    ORDER BY p.nome;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.buscar_produtos_disponiveis(text) OWNER TO postgres;
GRANT ALL ON FUNCTION public.buscar_produtos_disponiveis(text) TO public;
GRANT ALL ON FUNCTION public.buscar_produtos_disponiveis(text) TO postgres;
GRANT ALL ON FUNCTION public.buscar_produtos_disponiveis(text) TO anon;
GRANT ALL ON FUNCTION public.buscar_produtos_disponiveis(text) TO authenticated;
GRANT ALL ON FUNCTION public.buscar_produtos_disponiveis(text) TO service_role;

-- DROP FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric);

CREATE OR REPLACE FUNCTION public.calcular_impostos_produto(p_produto_id uuid, p_estado_destino character varying DEFAULT NULL::character varying, p_quantidade numeric DEFAULT 1.00, p_preco_unitario numeric DEFAULT 0.00)
 RETURNS TABLE(aliquota_icms numeric, aliquota_pis numeric, aliquota_cofins numeric, aliquota_ipi numeric, valor_icms numeric, valor_pis numeric, valor_cofins numeric, valor_ipi numeric, valor_total_impostos numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_empresa RECORD;
    v_produto RECORD;
    v_cat_imposto RECORD;
    v_aliq_icms NUMERIC;
    v_aliq_pis NUMERIC;
    v_aliq_cofins NUMERIC;
    v_aliq_ipi NUMERIC;
    v_base_calculo NUMERIC;
BEGIN
    -- Obter empresa
    SELECT * INTO v_empresa FROM empresa_config LIMIT 1;
    
    -- Obter produto
    SELECT * INTO v_produto FROM produtos WHERE id = p_produto_id;
    
    IF v_produto IS NULL THEN
        RAISE EXCEPTION 'Produto não encontrado';
    END IF;
    
    -- Obter alíquotas da categoria
    SELECT * INTO v_cat_imposto 
    FROM categoria_impostos 
    WHERE categoria_id = v_produto.categoria_id;
    
    -- Se não tiver alíquota da categoria, usar do produto
    IF v_cat_imposto IS NULL THEN
        v_aliq_icms := v_produto.aliquota_icms;
        v_aliq_pis := v_produto.aliquota_pis;
        v_aliq_cofins := v_produto.aliquota_cofins;
        v_aliq_ipi := v_produto.aliquota_ipi;
    ELSE
        v_aliq_icms := v_cat_imposto.aliquota_icms;
        v_aliq_pis := v_cat_imposto.aliquota_pis;
        v_aliq_cofins := v_cat_imposto.aliquota_cofins;
        v_aliq_ipi := v_cat_imposto.aliquota_ipi;
    END IF;
    
    -- Calcular base
    v_base_calculo := p_quantidade * p_preco_unitario;
    
    -- Retornar
    RETURN QUERY
    SELECT 
        v_aliq_icms,
        v_aliq_pis,
        v_aliq_cofins,
        v_aliq_ipi,
        ROUND((v_base_calculo * v_aliq_icms / 100), 2),
        ROUND((v_base_calculo * v_aliq_pis / 100), 2),
        ROUND((v_base_calculo * v_aliq_cofins / 100), 2),
        ROUND((v_base_calculo * v_aliq_ipi / 100), 2),
        ROUND((v_base_calculo * (v_aliq_icms + v_aliq_pis + v_aliq_cofins + v_aliq_ipi) / 100), 2);
END;
$function$
;

-- Permissions

ALTER FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) OWNER TO postgres;
GRANT ALL ON FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) TO public;
GRANT ALL ON FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) TO postgres;
GRANT ALL ON FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) TO anon;
GRANT ALL ON FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) TO authenticated;
GRANT ALL ON FUNCTION public.calcular_impostos_produto(uuid, varchar, numeric, numeric) TO service_role;

-- DROP FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida);

CREATE OR REPLACE FUNCTION public.converter_unidade(p_valor numeric, p_de_unidade unidade_medida, p_para_unidade unidade_medida)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN CASE 
        WHEN p_de_unidade = 'CX' AND p_para_unidade = 'UN' THEN p_valor * 12
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'CX' THEN p_valor / 12
        WHEN p_de_unidade = 'FD' AND p_para_unidade = 'UN' THEN p_valor * 6
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'FD' THEN p_valor / 6
        WHEN p_de_unidade = 'DZ' AND p_para_unidade = 'UN' THEN p_valor * 12
        WHEN p_de_unidade = 'UN' AND p_para_unidade = 'DZ' THEN p_valor / 12
        ELSE p_valor
    END;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) OWNER TO postgres;
GRANT ALL ON FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) TO public;
GRANT ALL ON FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) TO postgres;
GRANT ALL ON FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) TO anon;
GRANT ALL ON FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) TO authenticated;
GRANT ALL ON FUNCTION public.converter_unidade(numeric, unidade_medida, unidade_medida) TO service_role;

-- DROP FUNCTION public.crypt(text, text);

CREATE OR REPLACE FUNCTION public.crypt(text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_crypt$function$
;

-- Permissions

ALTER FUNCTION public.crypt(text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.crypt(text, text) TO supabase_admin;

-- DROP FUNCTION public.dearmor(text);

CREATE OR REPLACE FUNCTION public.dearmor(text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_dearmor$function$
;

-- Permissions

ALTER FUNCTION public.dearmor(text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.dearmor(text) TO supabase_admin;

-- DROP FUNCTION public.decrypt(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.decrypt(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_decrypt$function$
;

-- Permissions

ALTER FUNCTION public.decrypt(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.decrypt_iv(bytea, bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.decrypt_iv(bytea, bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_decrypt_iv$function$
;

-- Permissions

ALTER FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.digest(bytea, text);

CREATE OR REPLACE FUNCTION public.digest(bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_digest$function$
;

-- Permissions

ALTER FUNCTION public.digest(bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO supabase_admin;

-- DROP FUNCTION public.digest(text, text);

CREATE OR REPLACE FUNCTION public.digest(text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_digest$function$
;

-- Permissions

ALTER FUNCTION public.digest(text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.digest(text, text) TO supabase_admin;

-- DROP FUNCTION public.encrypt(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.encrypt(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_encrypt$function$
;

-- Permissions

ALTER FUNCTION public.encrypt(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.encrypt_iv(bytea, bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.encrypt_iv(bytea, bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_encrypt_iv$function$
;

-- Permissions

ALTER FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.fechar_caixa(uuid, numeric);

CREATE OR REPLACE FUNCTION public.fechar_caixa(p_movimentacao_id uuid, p_saldo_final numeric)
 RETURNS TABLE(sucesso boolean, mensagem text, diferenca numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_total_vendas NUMERIC;
    v_diferenca NUMERIC;
BEGIN
    -- Calcular total de vendas
    SELECT COALESCE(SUM(total), 0) INTO v_total_vendas
    FROM vendas
    WHERE movimentacao_caixa_id = p_movimentacao_id
    AND status_venda = 'FINALIZADA';

    -- Calcular diferença
    v_diferenca := p_saldo_final - (
        (SELECT saldo_inicial FROM movimentacoes_caixa WHERE id = p_movimentacao_id) + 
        v_total_vendas
    );

    -- Atualizar movimentação
    UPDATE movimentacoes_caixa
    SET 
        data_fechamento = NOW(),
        total_vendas = v_total_vendas,
        saldo_final = p_saldo_final,
        status = 'FECHADA'
    WHERE id = p_movimentacao_id;

    RETURN QUERY SELECT 
        true,
        CASE 
            WHEN v_diferenca = 0 THEN 'Caixa fechado com precisão'
            WHEN v_diferenca > 0 THEN 'Caixa com excesso de: ' || v_diferenca::text
            ELSE 'Caixa com falta de: ' || (v_diferenca * -1)::text
        END,
        v_diferenca;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.fechar_caixa(uuid, numeric) OWNER TO postgres;
GRANT ALL ON FUNCTION public.fechar_caixa(uuid, numeric) TO public;
GRANT ALL ON FUNCTION public.fechar_caixa(uuid, numeric) TO postgres;
GRANT ALL ON FUNCTION public.fechar_caixa(uuid, numeric) TO anon;
GRANT ALL ON FUNCTION public.fechar_caixa(uuid, numeric) TO authenticated;
GRANT ALL ON FUNCTION public.fechar_caixa(uuid, numeric) TO service_role;

-- DROP FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric);

CREATE OR REPLACE FUNCTION public.finalizar_venda_segura(p_numero_nf character varying, p_caixa_id uuid, p_movimentacao_caixa_id uuid, p_operador_id uuid, p_subtotal numeric, p_desconto numeric, p_acrescimo numeric, p_total numeric, p_forma_pagamento pagamento_forma, p_valor_pago numeric, p_valor_troco numeric)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_venda_id UUID;
BEGIN
    -- Usar transação implícita do PL/pgSQL
    -- Buscar com lock (FOR UPDATE) para evitar race condition
    
    INSERT INTO vendas (
        numero_nf,
        caixa_id,
        movimentacao_caixa_id,
        operador_id,
        subtotal,
        desconto,
        desconto_percentual,
        acrescimo,
        total,
        forma_pagamento,
        valor_pago,
        valor_troco,
        status_venda,
        status_fiscal
    ) VALUES (
        p_numero_nf,
        p_caixa_id,
        p_movimentacao_caixa_id,
        p_operador_id,
        p_subtotal,
        p_desconto,
        (p_desconto / p_subtotal * 100),
        p_acrescimo,
        p_total,
        p_forma_pagamento,
        p_valor_pago,
        p_valor_troco,
        'FINALIZADA',
        'SEM_DOCUMENTO_FISCAL'
    )
    RETURNING id INTO v_venda_id;

    -- Registrar pagamento
    INSERT INTO pagamentos_venda (
        venda_id,
        forma,
        valor,
        status_pagamento
    ) VALUES (
        v_venda_id,
        p_forma_pagamento,
        p_valor_pago,
        'RECEBIDO'
    );

    RETURN v_venda_id;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) OWNER TO postgres;
GRANT ALL ON FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) TO public;
GRANT ALL ON FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) TO postgres;
GRANT ALL ON FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) TO anon;
GRANT ALL ON FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) TO authenticated;
GRANT ALL ON FUNCTION public.finalizar_venda_segura(varchar, uuid, uuid, uuid, numeric, numeric, numeric, numeric, pagamento_forma, numeric, numeric) TO service_role;

-- DROP FUNCTION public.gen_random_bytes(int4);

CREATE OR REPLACE FUNCTION public.gen_random_bytes(integer)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_random_bytes$function$
;

-- Permissions

ALTER FUNCTION public.gen_random_bytes(int4) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.gen_random_bytes(int4) TO supabase_admin;

-- DROP FUNCTION public.gen_random_uuid();

CREATE OR REPLACE FUNCTION public.gen_random_uuid()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/pgcrypto', $function$pg_random_uuid$function$
;

-- Permissions

ALTER FUNCTION public.gen_random_uuid() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO supabase_admin;

-- DROP FUNCTION public.gen_salt(text);

CREATE OR REPLACE FUNCTION public.gen_salt(text)
 RETURNS text
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_gen_salt$function$
;

-- Permissions

ALTER FUNCTION public.gen_salt(text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.gen_salt(text) TO supabase_admin;

-- DROP FUNCTION public.gen_salt(text, int4);

CREATE OR REPLACE FUNCTION public.gen_salt(text, integer)
 RETURNS text
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_gen_salt_rounds$function$
;

-- Permissions

ALTER FUNCTION public.gen_salt(text, int4) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.gen_salt(text, int4) TO supabase_admin;

-- DROP FUNCTION public.gerar_numero_nfce();

CREATE OR REPLACE FUNCTION public.gerar_numero_nfce()
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_numero INTEGER;
    v_empresa_id UUID;
BEGIN
    -- Buscar ID da empresa (primeira config)
    SELECT id INTO v_empresa_id FROM empresa_config LIMIT 1;

    -- Incrementar número
    UPDATE empresa_config
    SET nfce_numero = nfce_numero + 1
    WHERE id = v_empresa_id;

    -- Retornar número formatado
    SELECT nfce_numero INTO v_numero FROM empresa_config WHERE id = v_empresa_id;
    
    RETURN LPAD(v_numero::text, 6, '0');
END;
$function$
;

-- Permissions

ALTER FUNCTION public.gerar_numero_nfce() OWNER TO postgres;
GRANT ALL ON FUNCTION public.gerar_numero_nfce() TO public;
GRANT ALL ON FUNCTION public.gerar_numero_nfce() TO postgres;
GRANT ALL ON FUNCTION public.gerar_numero_nfce() TO anon;
GRANT ALL ON FUNCTION public.gerar_numero_nfce() TO authenticated;
GRANT ALL ON FUNCTION public.gerar_numero_nfce() TO service_role;

-- DROP FUNCTION public.gerar_numero_venda();

CREATE OR REPLACE FUNCTION public.gerar_numero_venda()
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN 'PED-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(nextval('vendas_numero_seq')::TEXT, 6, '0');
END;
$function$
;

-- Permissions

ALTER FUNCTION public.gerar_numero_venda() OWNER TO postgres;
GRANT ALL ON FUNCTION public.gerar_numero_venda() TO public;
GRANT ALL ON FUNCTION public.gerar_numero_venda() TO postgres;
GRANT ALL ON FUNCTION public.gerar_numero_venda() TO anon;
GRANT ALL ON FUNCTION public.gerar_numero_venda() TO authenticated;
GRANT ALL ON FUNCTION public.gerar_numero_venda() TO service_role;

-- DROP FUNCTION public.get_preco_custo_para_venda(uuid, uuid);

CREATE OR REPLACE FUNCTION public.get_preco_custo_para_venda(p_produto_id uuid, p_lote_id uuid DEFAULT NULL::uuid)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_preco_custo DECIMAL(12,2);
BEGIN
    -- 1. Tentar buscar do lote específico
    IF p_lote_id IS NOT NULL THEN
        SELECT preco_custo INTO v_preco_custo
        FROM produto_lotes
        WHERE id = p_lote_id;
        
        IF v_preco_custo IS NOT NULL AND v_preco_custo > 0 THEN
            RETURN v_preco_custo;
        END IF;
    END IF;
    
    -- 2. Buscar do último pedido de compra recebido
    SELECT pci.preco_unitario INTO v_preco_custo
    FROM pedido_compra_itens pci
    JOIN pedidos_compra pc ON pci.pedido_id = pc.id
    WHERE pci.produto_id = p_produto_id
    AND pc.status = 'RECEBIDO'
    AND pci.quantidade_recebida > 0
    ORDER BY pc.data_recebimento DESC, pc.created_at DESC
    LIMIT 1;
    
    IF v_preco_custo IS NOT NULL AND v_preco_custo > 0 THEN
        RETURN v_preco_custo;
    END IF;
    
    -- 3. Fallback: usar preco_custo do cadastro do produto
    SELECT preco_custo INTO v_preco_custo
    FROM produtos
    WHERE id = p_produto_id;
    
    RETURN COALESCE(v_preco_custo, 0);
END;
$function$
;

-- Permissions

ALTER FUNCTION public.get_preco_custo_para_venda(uuid, uuid) OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_preco_custo_para_venda(uuid, uuid) TO public;
GRANT ALL ON FUNCTION public.get_preco_custo_para_venda(uuid, uuid) TO postgres;
GRANT ALL ON FUNCTION public.get_preco_custo_para_venda(uuid, uuid) TO anon;
GRANT ALL ON FUNCTION public.get_preco_custo_para_venda(uuid, uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_preco_custo_para_venda(uuid, uuid) TO service_role;

-- DROP FUNCTION public.hmac(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.hmac(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_hmac$function$
;

-- Permissions

ALTER FUNCTION public.hmac(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.hmac(text, text, text);

CREATE OR REPLACE FUNCTION public.hmac(text, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pg_hmac$function$
;

-- Permissions

ALTER FUNCTION public.hmac(text, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_armor_headers(in text, out text, out text);

CREATE OR REPLACE FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_armor_headers$function$
;

-- Permissions

ALTER FUNCTION public.pgp_armor_headers(in text, out text, out text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_armor_headers(in text, out text, out text) TO supabase_admin;

-- DROP FUNCTION public.pgp_key_id(bytea);

CREATE OR REPLACE FUNCTION public.pgp_key_id(bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_key_id_w$function$
;

-- Permissions

ALTER FUNCTION public.pgp_key_id(bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt(bytea, bytea);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt(bytea, bytea)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt(bytea, bytea, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_decrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_encrypt(text, bytea);

CREATE OR REPLACE FUNCTION public.pgp_pub_encrypt(text, bytea)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_encrypt(text, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_encrypt(text, bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_encrypt(text, bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_encrypt(text, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea);

CREATE OR REPLACE FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO supabase_admin;

-- DROP FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_pub_encrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_decrypt(bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_decrypt(bytea, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_decrypt(bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_decrypt(bytea, text, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_decrypt(bytea, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_decrypt(bytea, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_decrypt_bytea(bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_decrypt_bytea(bytea, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_decrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_encrypt(text, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_encrypt(text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_encrypt(text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_encrypt(text, text, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_encrypt(text, text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_text$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_encrypt(text, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_encrypt_bytea(bytea, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_encrypt_bytea(bytea, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO supabase_admin;

-- DROP FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text);

CREATE OR REPLACE FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text)
 RETURNS bytea
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pgcrypto', $function$pgp_sym_encrypt_bytea$function$
;

-- Permissions

ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO supabase_admin;

-- DROP FUNCTION public.processar_entradas_compras();

CREATE OR REPLACE FUNCTION public.processar_entradas_compras()
 RETURNS TABLE(produto_id uuid, produto_nome character varying, quantidade_total numeric, preco_custo numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    WITH entradas AS (
        SELECT 
            pci.produto_id,
            p.nome AS produto_nome,
            SUM(pci.quantidade) AS quantidade_total,
            pci.preco_unitario AS preco_custo
        FROM public.pedido_compra_itens pci
        JOIN public.pedidos_compra pc ON pci.pedido_id = pc.id
        JOIN public.produtos p ON pci.produto_id = p.id
        WHERE pc.status = 'RECEBIDO'  -- Apenas pedidos recebidos
        GROUP BY pci.produto_id, p.nome, pci.preco_unitario
    )
    UPDATE public.produtos p
    SET estoque_atual = estoque_atual + e.quantidade_total
    FROM entradas e
    WHERE p.id = e.produto_id
    RETURNING 
        e.produto_id,
        e.produto_nome,
        e.quantidade_total,
        e.preco_custo;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.processar_entradas_compras() OWNER TO postgres;
GRANT ALL ON FUNCTION public.processar_entradas_compras() TO public;
GRANT ALL ON FUNCTION public.processar_entradas_compras() TO postgres;
GRANT ALL ON FUNCTION public.processar_entradas_compras() TO anon;
GRANT ALL ON FUNCTION public.processar_entradas_compras() TO authenticated;
GRANT ALL ON FUNCTION public.processar_entradas_compras() TO service_role;

-- DROP FUNCTION public.processar_saidas_vendas();

CREATE OR REPLACE FUNCTION public.processar_saidas_vendas()
 RETURNS TABLE(produto_id uuid, produto_nome character varying, quantidade_total numeric, preco_venda numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    WITH saidas AS (
        SELECT 
            vi.produto_id,
            p.nome AS produto_nome,
            SUM(vi.quantidade) AS quantidade_total,
            vi.preco_unitario AS preco_venda
        FROM public.vendas_itens vi
        JOIN public.vendas v ON vi.venda_id = v.id
        JOIN public.produtos p ON vi.produto_id = p.id
        WHERE v.status = 'FINALIZADA'  -- Apenas vendas finalizadas
        GROUP BY vi.produto_id, p.nome, vi.preco_unitario
    )
    UPDATE public.produtos p
    SET estoque_atual = estoque_atual - s.quantidade_total
    FROM saidas s
    WHERE p.id = s.produto_id
    AND estoque_atual >= s.quantidade_total  -- Validação!
    RETURNING 
        s.produto_id,
        s.produto_nome,
        s.quantidade_total,
        s.preco_venda;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.processar_saidas_vendas() OWNER TO postgres;
GRANT ALL ON FUNCTION public.processar_saidas_vendas() TO public;
GRANT ALL ON FUNCTION public.processar_saidas_vendas() TO postgres;
GRANT ALL ON FUNCTION public.processar_saidas_vendas() TO anon;
GRANT ALL ON FUNCTION public.processar_saidas_vendas() TO authenticated;
GRANT ALL ON FUNCTION public.processar_saidas_vendas() TO service_role;

-- DROP FUNCTION public.reprocessar_estoque_novo();

CREATE OR REPLACE FUNCTION public.reprocessar_estoque_novo()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Log de início
    RAISE NOTICE '========================================';
    RAISE NOTICE 'INICIANDO REPROCESSAMENTO DE ESTOQUE';
    RAISE NOTICE '========================================';
    
    -- ETAPA 1: Zerar
    RAISE NOTICE '1️⃣  Zerando estoque...';
    PERFORM zerar_estoque_completo();
    RAISE NOTICE '   ✅ Estoque zerado com sucesso';
    
    -- ETAPA 2: Processar Entradas
    RAISE NOTICE '2️⃣  Processando entradas de compras...';
    PERFORM processar_entradas_compras();
    RAISE NOTICE '   ✅ Entradas processadas com sucesso';
    
    -- ETAPA 3: Processar Saídas
    RAISE NOTICE '3️⃣  Processando saídas de vendas...';
    PERFORM processar_saidas_vendas();
    RAISE NOTICE '   ✅ Saídas processadas com sucesso';
    
    -- ETAPA 4: Atualizar Lotes
    RAISE NOTICE '4️⃣  Atualizando quantidade de lotes...';
    PERFORM atualizar_quantidade_lotes();
    RAISE NOTICE '   ✅ Lotes atualizados com sucesso';
    
    -- ETAPA 5: Validar
    RAISE NOTICE '5️⃣  Validando consistência...';
    PERFORM validar_consistencia_estoque();
    RAISE NOTICE '   ✅ Validação concluída com sucesso';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'REPROCESSAMENTO CONCLUÍDO!';
    RAISE NOTICE '========================================';
END;
$function$
;

-- Permissions

ALTER FUNCTION public.reprocessar_estoque_novo() OWNER TO postgres;
GRANT ALL ON FUNCTION public.reprocessar_estoque_novo() TO public;
GRANT ALL ON FUNCTION public.reprocessar_estoque_novo() TO postgres;
GRANT ALL ON FUNCTION public.reprocessar_estoque_novo() TO anon;
GRANT ALL ON FUNCTION public.reprocessar_estoque_novo() TO authenticated;
GRANT ALL ON FUNCTION public.reprocessar_estoque_novo() TO service_role;

-- DROP FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric);

CREATE OR REPLACE FUNCTION public.stats_vendas_dia(OUT total_vendas numeric, OUT quantidade_itens integer, OUT media_venda numeric)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
BEGIN
    SELECT 
        COALESCE(SUM(v.total), 0),
        COALESCE(COUNT(DISTINCT vi.id), 0),
        COALESCE(AVG(v.total), 0)
    INTO total_vendas, quantidade_itens, media_venda
    FROM vendas v
    LEFT JOIN vendas_itens vi ON v.id = vi.venda_id
    WHERE DATE(v.created_at) = CURRENT_DATE
    AND v.status_venda = 'FINALIZADA';
END;
$function$
;

-- Permissions

ALTER FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) OWNER TO postgres;
GRANT ALL ON FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) TO public;
GRANT ALL ON FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) TO postgres;
GRANT ALL ON FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) TO anon;
GRANT ALL ON FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) TO authenticated;
GRANT ALL ON FUNCTION public.stats_vendas_dia(out numeric, out int4, out numeric) TO service_role;

-- DROP FUNCTION public.trg_venda_item_set_preco_custo();

CREATE OR REPLACE FUNCTION public.trg_venda_item_set_preco_custo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Se preco_custo não foi informado, buscar automaticamente
    IF NEW.preco_custo IS NULL OR NEW.preco_custo = 0 THEN
        NEW.preco_custo := get_preco_custo_para_venda(NEW.produto_id, NEW.lote_id);
    END IF;
    
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.trg_venda_item_set_preco_custo() OWNER TO postgres;
GRANT ALL ON FUNCTION public.trg_venda_item_set_preco_custo() TO public;
GRANT ALL ON FUNCTION public.trg_venda_item_set_preco_custo() TO postgres;
GRANT ALL ON FUNCTION public.trg_venda_item_set_preco_custo() TO anon;
GRANT ALL ON FUNCTION public.trg_venda_item_set_preco_custo() TO authenticated;
GRANT ALL ON FUNCTION public.trg_venda_item_set_preco_custo() TO service_role;

-- DROP FUNCTION public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO public;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO postgres;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;

-- DROP FUNCTION public.uuid_generate_v1();

CREATE OR REPLACE FUNCTION public.uuid_generate_v1()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1$function$
;

-- Permissions

ALTER FUNCTION public.uuid_generate_v1() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_generate_v1() TO supabase_admin;

-- DROP FUNCTION public.uuid_generate_v1mc();

CREATE OR REPLACE FUNCTION public.uuid_generate_v1mc()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1mc$function$
;

-- Permissions

ALTER FUNCTION public.uuid_generate_v1mc() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_generate_v1mc() TO supabase_admin;

-- DROP FUNCTION public.uuid_generate_v3(uuid, text);

CREATE OR REPLACE FUNCTION public.uuid_generate_v3(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v3$function$
;

-- Permissions

ALTER FUNCTION public.uuid_generate_v3(uuid, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_generate_v3(uuid, text) TO supabase_admin;

-- DROP FUNCTION public.uuid_generate_v4();

CREATE OR REPLACE FUNCTION public.uuid_generate_v4()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v4$function$
;

-- Permissions

ALTER FUNCTION public.uuid_generate_v4() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_generate_v4() TO supabase_admin;

-- DROP FUNCTION public.uuid_generate_v5(uuid, text);

CREATE OR REPLACE FUNCTION public.uuid_generate_v5(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v5$function$
;

-- Permissions

ALTER FUNCTION public.uuid_generate_v5(uuid, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_generate_v5(uuid, text) TO supabase_admin;

-- DROP FUNCTION public.uuid_nil();

CREATE OR REPLACE FUNCTION public.uuid_nil()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_nil$function$
;

-- Permissions

ALTER FUNCTION public.uuid_nil() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_nil() TO supabase_admin;

-- DROP FUNCTION public.uuid_ns_dns();

CREATE OR REPLACE FUNCTION public.uuid_ns_dns()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_dns$function$
;

-- Permissions

ALTER FUNCTION public.uuid_ns_dns() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_ns_dns() TO supabase_admin;

-- DROP FUNCTION public.uuid_ns_oid();

CREATE OR REPLACE FUNCTION public.uuid_ns_oid()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_oid$function$
;

-- Permissions

ALTER FUNCTION public.uuid_ns_oid() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_ns_oid() TO supabase_admin;

-- DROP FUNCTION public.uuid_ns_url();

CREATE OR REPLACE FUNCTION public.uuid_ns_url()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_url$function$
;

-- Permissions

ALTER FUNCTION public.uuid_ns_url() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_ns_url() TO supabase_admin;

-- DROP FUNCTION public.uuid_ns_x500();

CREATE OR REPLACE FUNCTION public.uuid_ns_x500()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_x500$function$
;

-- Permissions

ALTER FUNCTION public.uuid_ns_x500() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION public.uuid_ns_x500() TO supabase_admin;

-- DROP FUNCTION public.validar_consistencia_estoque();

CREATE OR REPLACE FUNCTION public.validar_consistencia_estoque()
 RETURNS TABLE(produto_id uuid, produto_nome character varying, estoque_atual numeric, entradas_total numeric, saidas_total numeric, estoque_calculado numeric, status character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    WITH movimentacao AS (
        -- Entradas de compras
        SELECT 
            pci.produto_id,
            'ENTRADA'::VARCHAR AS tipo,
            SUM(pci.quantidade) AS quantidade
        FROM public.pedido_compra_itens pci
        JOIN public.pedidos_compra pc ON pci.pedido_id = pc.id
        WHERE pc.status = 'RECEBIDO'
        GROUP BY pci.produto_id
        
        UNION ALL
        
        -- Saídas de vendas
        SELECT 
            vi.produto_id,
            'SAIDA'::VARCHAR,
            -SUM(vi.quantidade)
        FROM public.vendas_itens vi
        JOIN public.vendas v ON vi.venda_id = v.id
        WHERE v.status = 'FINALIZADA'
        GROUP BY vi.produto_id
    ),
    resumo AS (
        SELECT 
            p.id AS produto_id,
            p.nome AS produto_nome,
            p.estoque_atual,
            COALESCE(
                SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.quantidade ELSE 0 END), 0
            ) AS entradas_total,
            COALESCE(
                SUM(CASE WHEN m.tipo = 'SAIDA' THEN -m.quantidade ELSE 0 END), 0
            ) AS saidas_total
        FROM public.produtos p
        LEFT JOIN movimentacao m ON p.id = m.produto_id
        GROUP BY p.id, p.nome, p.estoque_atual
    )
    SELECT 
        r.produto_id,
        r.produto_nome,
        r.estoque_atual,
        r.entradas_total,
        r.saidas_total,
        (r.entradas_total - r.saidas_total)::NUMERIC AS estoque_calculado,
        CASE 
            WHEN r.estoque_atual = (r.entradas_total - r.saidas_total) THEN 'OK'::VARCHAR
            ELSE 'DIVERGÊNCIA'::VARCHAR
        END AS status
    FROM resumo r
    WHERE r.estoque_atual > 0 OR r.entradas_total > 0 OR r.saidas_total > 0
    ORDER BY r.produto_nome;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.validar_consistencia_estoque() OWNER TO postgres;
GRANT ALL ON FUNCTION public.validar_consistencia_estoque() TO public;
GRANT ALL ON FUNCTION public.validar_consistencia_estoque() TO postgres;
GRANT ALL ON FUNCTION public.validar_consistencia_estoque() TO anon;
GRANT ALL ON FUNCTION public.validar_consistencia_estoque() TO authenticated;
GRANT ALL ON FUNCTION public.validar_consistencia_estoque() TO service_role;

-- DROP FUNCTION public.validar_cpf_cnpj(varchar);

CREATE OR REPLACE FUNCTION public.validar_cpf_cnpj(p_documento character varying)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_doc VARCHAR;
    v_sum INTEGER;
    v_resto INTEGER;
    i INTEGER;
BEGIN
    -- Remover caracteres especiais
    v_doc := regexp_replace(p_documento, '[^0-9]', '', 'g');

    -- Validar tamanho
    IF length(v_doc) NOT IN (11, 14) THEN
        RETURN false;
    END IF;

    -- Validar CPF (11 dígitos)
    IF length(v_doc) = 11 THEN
        -- Validação simplificada
        IF v_doc ~ '^[0-9]{11}$' THEN
            RETURN true;
        END IF;
    END IF;

    -- Validar CNPJ (14 dígitos)
    IF length(v_doc) = 14 THEN
        IF v_doc ~ '^[0-9]{14}$' THEN
            RETURN true;
        END IF;
    END IF;

    RETURN false;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.validar_cpf_cnpj(varchar) OWNER TO postgres;
GRANT ALL ON FUNCTION public.validar_cpf_cnpj(varchar) TO public;
GRANT ALL ON FUNCTION public.validar_cpf_cnpj(varchar) TO postgres;
GRANT ALL ON FUNCTION public.validar_cpf_cnpj(varchar) TO anon;
GRANT ALL ON FUNCTION public.validar_cpf_cnpj(varchar) TO authenticated;
GRANT ALL ON FUNCTION public.validar_cpf_cnpj(varchar) TO service_role;

-- DROP FUNCTION public.validar_dados_emissao_fiscal();

CREATE OR REPLACE FUNCTION public.validar_dados_emissao_fiscal()
 RETURNS TABLE(campo character varying, status character varying, mensagem text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_empresa RECORD;
    v_problemas INT := 0;
BEGIN
    SELECT * INTO v_empresa FROM empresa_config LIMIT 1;
    
    -- Verificar empresa
    IF v_empresa IS NULL THEN
        RETURN QUERY SELECT 'empresa_config'::VARCHAR, 'ERRO'::VARCHAR, 'Nenhuma empresa configurada'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Verificar campos obrigatórios
    IF v_empresa.cnpj IS NULL OR v_empresa.cnpj = '' THEN
        RETURN QUERY SELECT 'empresa.cnpj'::VARCHAR, 'ERRO'::VARCHAR, 'CNPJ não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.inscricao_estadual IS NULL OR v_empresa.inscricao_estadual = '' THEN
        RETURN QUERY SELECT 'empresa.inscricao_estadual'::VARCHAR, 'ERRO'::VARCHAR, 'IE não preenchida'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.logradouro IS NULL OR v_empresa.logradouro = '' THEN
        RETURN QUERY SELECT 'empresa.logradouro'::VARCHAR, 'ERRO'::VARCHAR, 'Logradouro não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.codigo_municipio IS NULL OR v_empresa.codigo_municipio = '' THEN
        RETURN QUERY SELECT 'empresa.codigo_municipio'::VARCHAR, 'ERRO'::VARCHAR, 'Código município IBGE não preenchido'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.nfe_token IS NULL OR v_empresa.nfe_token = '' THEN
        RETURN QUERY SELECT 'empresa.nfe_token'::VARCHAR, 'AVISO'::VARCHAR, 'Token Focus NFe não configurado (emissão não funcionará)'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    IF v_empresa.certificado_digital IS NULL OR v_empresa.certificado_digital = '' THEN
        RETURN QUERY SELECT 'empresa.certificado_digital'::VARCHAR, 'AVISO'::VARCHAR, 'Certificado digital não carregado'::TEXT;
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Verificar produtos
    IF (SELECT COUNT(*) FROM produtos WHERE ncm IS NULL OR ncm = '') > 0 THEN
        RETURN QUERY SELECT 'produtos.ncm'::VARCHAR, 'AVISO'::VARCHAR, CONCAT((SELECT COUNT(*) FROM produtos WHERE ncm IS NULL OR ncm = ''), ' produtos sem NCM'::TEXT);
        v_problemas := v_problemas + 1;
    END IF;
    
    IF (SELECT COUNT(*) FROM produtos WHERE cfop IS NULL OR cfop = '') > 0 THEN
        RETURN QUERY SELECT 'produtos.cfop'::VARCHAR, 'AVISO'::VARCHAR, CONCAT((SELECT COUNT(*) FROM produtos WHERE cfop IS NULL OR cfop = ''), ' produtos sem CFOP'::TEXT);
        v_problemas := v_problemas + 1;
    END IF;
    
    -- Resultado final
    IF v_problemas = 0 THEN
        RETURN QUERY SELECT 'GERAL'::VARCHAR, 'OK'::VARCHAR, 'Sistema pronto para emissão fiscal'::TEXT;
    ELSE
        RETURN QUERY SELECT 'GERAL'::VARCHAR, 'CRÍTICO'::VARCHAR, CONCAT(v_problemas, ' problemas encontrados'::TEXT);
    END IF;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.validar_dados_emissao_fiscal() OWNER TO postgres;
GRANT ALL ON FUNCTION public.validar_dados_emissao_fiscal() TO public;
GRANT ALL ON FUNCTION public.validar_dados_emissao_fiscal() TO postgres;
GRANT ALL ON FUNCTION public.validar_dados_emissao_fiscal() TO anon;
GRANT ALL ON FUNCTION public.validar_dados_emissao_fiscal() TO authenticated;
GRANT ALL ON FUNCTION public.validar_dados_emissao_fiscal() TO service_role;

-- DROP FUNCTION public.validar_estoque_positivo();

CREATE OR REPLACE FUNCTION public.validar_estoque_positivo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.estoque_atual < 0 THEN
        RAISE EXCEPTION 'Estoque não pode ser negativo para o produto %', NEW.nome;
    END IF;
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.validar_estoque_positivo() OWNER TO postgres;
GRANT ALL ON FUNCTION public.validar_estoque_positivo() TO public;
GRANT ALL ON FUNCTION public.validar_estoque_positivo() TO postgres;
GRANT ALL ON FUNCTION public.validar_estoque_positivo() TO anon;
GRANT ALL ON FUNCTION public.validar_estoque_positivo() TO authenticated;
GRANT ALL ON FUNCTION public.validar_estoque_positivo() TO service_role;

-- DROP FUNCTION public.validar_sku_unico();

CREATE OR REPLACE FUNCTION public.validar_sku_unico()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Valida apenas se SKU não é NULL e não é vazio
    IF NEW.sku IS NOT NULL AND NEW.sku != '' THEN
        -- Verifica se já existe outro produto com este SKU
        IF EXISTS (
            SELECT 1 FROM produtos 
            WHERE sku = NEW.sku 
            AND id != NEW.id  -- Ignora o próprio registro em UPDATE
        ) THEN
            RAISE EXCEPTION 'Erro: SKU "%" já existe em outro produto!', NEW.sku;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.validar_sku_unico() OWNER TO postgres;
GRANT ALL ON FUNCTION public.validar_sku_unico() TO public;
GRANT ALL ON FUNCTION public.validar_sku_unico() TO postgres;
GRANT ALL ON FUNCTION public.validar_sku_unico() TO anon;
GRANT ALL ON FUNCTION public.validar_sku_unico() TO authenticated;
GRANT ALL ON FUNCTION public.validar_sku_unico() TO service_role;

-- DROP FUNCTION public.verificar_acesso_role(uuid, user_role);

CREATE OR REPLACE FUNCTION public.verificar_acesso_role(p_usuario_id uuid, p_role user_role)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_user_role user_role;
BEGIN
    SELECT role INTO v_user_role FROM users WHERE id = p_usuario_id;
    RETURN v_user_role = p_role OR v_user_role = 'ADMIN';
END;
$function$
;

-- Permissions

ALTER FUNCTION public.verificar_acesso_role(uuid, user_role) OWNER TO postgres;
GRANT ALL ON FUNCTION public.verificar_acesso_role(uuid, user_role) TO public;
GRANT ALL ON FUNCTION public.verificar_acesso_role(uuid, user_role) TO postgres;
GRANT ALL ON FUNCTION public.verificar_acesso_role(uuid, user_role) TO anon;
GRANT ALL ON FUNCTION public.verificar_acesso_role(uuid, user_role) TO authenticated;
GRANT ALL ON FUNCTION public.verificar_acesso_role(uuid, user_role) TO service_role;

-- DROP FUNCTION public.zerar_estoque_completo();

CREATE OR REPLACE FUNCTION public.zerar_estoque_completo()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Zerar estoque dos produtos (WHERE garante segurança)
    UPDATE public.produtos SET estoque_atual = 0 WHERE estoque_atual <> 0;
    
    -- Zerar quantidade dos lotes (WHERE garante segurança)
    UPDATE public.produto_lotes SET quantidade_atual = 0 WHERE quantidade_atual <> 0;
    
    RAISE NOTICE '✅ Estoque zerado com sucesso';
END;
$function$
;

-- Permissions

ALTER FUNCTION public.zerar_estoque_completo() OWNER TO postgres;
GRANT ALL ON FUNCTION public.zerar_estoque_completo() TO public;
GRANT ALL ON FUNCTION public.zerar_estoque_completo() TO postgres;
GRANT ALL ON FUNCTION public.zerar_estoque_completo() TO anon;
GRANT ALL ON FUNCTION public.zerar_estoque_completo() TO authenticated;
GRANT ALL ON FUNCTION public.zerar_estoque_completo() TO service_role;


-- Permissions

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, INSERT, DELETE, UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, INSERT, DELETE, UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, INSERT, DELETE, UPDATE ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT USAGE ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT USAGE ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT USAGE ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO service_role;

-- DROP SCHEMA realtime;

CREATE SCHEMA realtime AUTHORIZATION supabase_admin;

-- DROP TYPE realtime."action";

CREATE TYPE realtime."action" AS ENUM (
	'INSERT',
	'UPDATE',
	'DELETE',
	'TRUNCATE',
	'ERROR');

-- DROP TYPE realtime."equality_op";

CREATE TYPE realtime."equality_op" AS ENUM (
	'eq',
	'neq',
	'lt',
	'lte',
	'gt',
	'gte',
	'in');

-- DROP SEQUENCE realtime.subscription_id_seq;

CREATE SEQUENCE realtime.subscription_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE realtime.subscription_id_seq OWNER TO supabase_admin;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_admin;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;
-- realtime.messages definição

-- Drop table

-- DROP TABLE realtime.messages;

CREATE TABLE realtime.messages ( topic text NOT NULL, "extension" text NOT NULL, payload jsonb NULL, "event" text NULL, private bool DEFAULT false NULL, updated_at timestamp DEFAULT now() NOT NULL, inserted_at timestamp DEFAULT now() NOT NULL, id uuid DEFAULT gen_random_uuid() NOT NULL, CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at)) PARTITION BY RANGE (inserted_at);
CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

-- Permissions

ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;
GRANT ALL ON TABLE realtime.messages TO supabase_realtime_admin;
GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT, INSERT, UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT, INSERT, UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE realtime.messages TO service_role;


-- realtime.schema_migrations definição

-- Drop table

-- DROP TABLE realtime.schema_migrations;

CREATE TABLE realtime.schema_migrations ( "version" int8 NOT NULL, inserted_at timestamp(0) NULL, CONSTRAINT schema_migrations_pkey PRIMARY KEY (version));

-- Permissions

ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_admin;
GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


-- realtime."subscription" definição

-- Drop table

-- DROP TABLE realtime."subscription";

CREATE TABLE realtime."subscription" ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, subscription_id uuid NOT NULL, entity regclass NOT NULL, filters realtime._user_defined_filter DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL, claims jsonb NOT NULL, claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole(claims ->> 'role'::text)) STORED NOT NULL, created_at timestamp DEFAULT timezone('utc'::text, now()) NOT NULL, action_filter text DEFAULT '*'::text NULL, CONSTRAINT pk_subscription PRIMARY KEY (id), CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text]))));
CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);
CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);

-- Table Triggers

create trigger tr_check_filters before
insert
    or
update
    on
    realtime.subscription for each row execute function realtime.subscription_check_filters();

-- Permissions

ALTER TABLE realtime."subscription" OWNER TO supabase_admin;
GRANT ALL ON TABLE realtime."subscription" TO supabase_admin;
GRANT ALL ON TABLE realtime."subscription" TO postgres;
GRANT ALL ON TABLE realtime."subscription" TO dashboard_user;
GRANT SELECT ON TABLE realtime."subscription" TO anon;
GRANT SELECT ON TABLE realtime."subscription" TO authenticated;
GRANT SELECT ON TABLE realtime."subscription" TO service_role;
GRANT ALL ON TABLE realtime."subscription" TO supabase_realtime_admin;



-- DROP FUNCTION realtime.apply_rls(jsonb, int4);

CREATE OR REPLACE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024))
 RETURNS SETOF realtime.wal_rls
 LANGUAGE plpgsql
AS $function$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$function$
;

-- Permissions

ALTER FUNCTION realtime.apply_rls(jsonb, int4) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO public;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(jsonb, int4) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text);

CREATE OR REPLACE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$function$
;

-- Permissions

ALTER FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text) TO public;
GRANT ALL ON FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(text, text, text, text, text, record, record, text) TO dashboard_user;

-- DROP FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column);

CREATE OR REPLACE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[])
 RETURNS text
 LANGUAGE sql
AS $function$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $function$
;

-- Permissions

ALTER FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO public;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(text, regclass, realtime._wal_column) TO supabase_realtime_admin;

-- DROP FUNCTION realtime."cast"(text, regtype);

CREATE OR REPLACE FUNCTION realtime."cast"(val text, type_ regtype)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $function$
;

-- Permissions

ALTER FUNCTION realtime."cast"(text, regtype) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO public;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO supabase_admin;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(text, regtype) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text);

CREATE OR REPLACE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $function$
;

-- Permissions

ALTER FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO public;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(realtime."equality_op", regtype, text, text) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter);

CREATE OR REPLACE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[])
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $function$
;

-- Permissions

ALTER FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO public;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(realtime._wal_column, realtime._user_defined_filter) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.list_changes(name, name, int4, int4);

CREATE OR REPLACE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer)
 RETURNS SETOF realtime.wal_rls
 LANGUAGE sql
 SET log_min_messages TO 'fatal'
AS $function$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $function$
;

-- Permissions

ALTER FUNCTION realtime.list_changes(name, name, int4, int4) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO public;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(name, name, int4, int4) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.quote_wal2json(regclass);

CREATE OR REPLACE FUNCTION realtime.quote_wal2json(entity regclass)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $function$
;

-- Permissions

ALTER FUNCTION realtime.quote_wal2json(regclass) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO public;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(regclass) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.send(jsonb, text, text, bool);

CREATE OR REPLACE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$function$
;

-- Permissions

ALTER FUNCTION realtime.send(jsonb, text, text, bool) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.send(jsonb, text, text, bool) TO public;
GRANT ALL ON FUNCTION realtime.send(jsonb, text, text, bool) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.send(jsonb, text, text, bool) TO postgres;
GRANT ALL ON FUNCTION realtime.send(jsonb, text, text, bool) TO dashboard_user;

-- DROP FUNCTION realtime.subscription_check_filters();

CREATE OR REPLACE FUNCTION realtime.subscription_check_filters()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $function$
;

-- Permissions

ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO public;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_admin;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;

-- DROP FUNCTION realtime.to_regrole(text);

CREATE OR REPLACE FUNCTION realtime.to_regrole(role_name text)
 RETURNS regrole
 LANGUAGE sql
 IMMUTABLE
AS $function$ select role_name::regrole $function$
;

-- Permissions

ALTER FUNCTION realtime.to_regrole(text) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO public;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO supabase_admin;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(text) TO supabase_realtime_admin;

-- DROP FUNCTION realtime.topic();

CREATE OR REPLACE FUNCTION realtime.topic()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
select nullif(current_setting('realtime.topic', true), '')::text;
$function$
;

-- Permissions

ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;
GRANT ALL ON FUNCTION realtime.topic() TO public;
GRANT ALL ON FUNCTION realtime.topic() TO supabase_realtime_admin;
GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


-- Permissions

GRANT ALL ON SCHEMA realtime TO supabase_admin;
GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT EXECUTE ON FUNCTIONS TO dashboard_user;

-- DROP SCHEMA "storage";

CREATE SCHEMA "storage" AUTHORIZATION supabase_admin;

-- DROP TYPE "storage"."buckettype";

CREATE TYPE "storage"."buckettype" AS ENUM (
	'STANDARD',
	'ANALYTICS',
	'VECTOR');
-- "storage".buckets definição

-- Drop table

-- DROP TABLE "storage".buckets;

CREATE TABLE "storage".buckets ( id text NOT NULL, "name" text NOT NULL, "owner" uuid NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, public bool DEFAULT false NULL, avif_autodetection bool DEFAULT false NULL, file_size_limit int8 NULL, allowed_mime_types _text NULL, owner_id text NULL, "type" "storage"."buckettype" DEFAULT 'STANDARD'::storage.buckettype NOT NULL, CONSTRAINT buckets_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);

-- Column comments

COMMENT ON COLUMN "storage".buckets."owner" IS 'Field is deprecated, use owner_id instead';

-- Table Triggers

create trigger enforce_bucket_name_length_trigger before
insert
    or
update
    of name on
    storage.buckets for each row execute function storage.enforce_bucket_name_length();
create trigger protect_buckets_delete before
delete
    on
    storage.buckets for each statement execute function storage.protect_delete();

-- Permissions

ALTER TABLE "storage".buckets OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".buckets TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".buckets TO service_role;
GRANT ALL ON TABLE "storage".buckets TO authenticated;
GRANT ALL ON TABLE "storage".buckets TO anon;
GRANT ALL ON TABLE "storage".buckets TO postgres;


-- "storage".buckets_analytics definição

-- Drop table

-- DROP TABLE "storage".buckets_analytics;

CREATE TABLE "storage".buckets_analytics ( "name" text NOT NULL, "type" "storage"."buckettype" DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL, format text DEFAULT 'ICEBERG'::text NOT NULL, created_at timestamptz DEFAULT now() NOT NULL, updated_at timestamptz DEFAULT now() NOT NULL, id uuid DEFAULT gen_random_uuid() NOT NULL, deleted_at timestamptz NULL, CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);

-- Permissions

ALTER TABLE "storage".buckets_analytics OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".buckets_analytics TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".buckets_analytics TO service_role;
GRANT ALL ON TABLE "storage".buckets_analytics TO authenticated;
GRANT ALL ON TABLE "storage".buckets_analytics TO anon;


-- "storage".buckets_vectors definição

-- Drop table

-- DROP TABLE "storage".buckets_vectors;

CREATE TABLE "storage".buckets_vectors ( id text NOT NULL, "type" "storage"."buckettype" DEFAULT 'VECTOR'::storage.buckettype NOT NULL, created_at timestamptz DEFAULT now() NOT NULL, updated_at timestamptz DEFAULT now() NOT NULL, CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE "storage".buckets_vectors OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".buckets_vectors TO supabase_storage_admin;
GRANT SELECT ON TABLE "storage".buckets_vectors TO service_role;
GRANT SELECT ON TABLE "storage".buckets_vectors TO authenticated;
GRANT SELECT ON TABLE "storage".buckets_vectors TO anon;


-- "storage".migrations definição

-- Drop table

-- DROP TABLE "storage".migrations;

CREATE TABLE "storage".migrations ( id int4 NOT NULL, "name" varchar(100) NOT NULL, hash varchar(40) NOT NULL, executed_at timestamp DEFAULT CURRENT_TIMESTAMP NULL, CONSTRAINT migrations_name_key UNIQUE (name), CONSTRAINT migrations_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE "storage".migrations OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".migrations TO supabase_storage_admin;


-- "storage".objects definição

-- Drop table

-- DROP TABLE "storage".objects;

CREATE TABLE "storage".objects ( id uuid DEFAULT gen_random_uuid() NOT NULL, bucket_id text NULL, "name" text NULL, "owner" uuid NULL, created_at timestamptz DEFAULT now() NULL, updated_at timestamptz DEFAULT now() NULL, last_accessed_at timestamptz DEFAULT now() NULL, metadata jsonb NULL, path_tokens _text GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED NULL, "version" text NULL, owner_id text NULL, user_metadata jsonb NULL, CONSTRAINT objects_pkey PRIMARY KEY (id), CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES "storage".buckets(id));
CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);
CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");
CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");
CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);

-- Column comments

COMMENT ON COLUMN "storage".objects."owner" IS 'Field is deprecated, use owner_id instead';

-- Table Triggers

create trigger protect_objects_delete before
delete
    on
    storage.objects for each statement execute function storage.protect_delete();
create trigger update_objects_updated_at before
update
    on
    storage.objects for each row execute function storage.update_updated_at_column();

-- Permissions

ALTER TABLE "storage".objects OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".objects TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".objects TO service_role;
GRANT ALL ON TABLE "storage".objects TO authenticated;
GRANT ALL ON TABLE "storage".objects TO anon;
GRANT ALL ON TABLE "storage".objects TO postgres;


-- "storage".s3_multipart_uploads definição

-- Drop table

-- DROP TABLE "storage".s3_multipart_uploads;

CREATE TABLE "storage".s3_multipart_uploads ( id text NOT NULL, in_progress_size int8 DEFAULT 0 NOT NULL, upload_signature text NOT NULL, bucket_id text NOT NULL, "key" text COLLATE "C" NOT NULL, "version" text NOT NULL, owner_id text NULL, created_at timestamptz DEFAULT now() NOT NULL, user_metadata jsonb NULL, CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id), CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES "storage".buckets(id));
CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);

-- Permissions

ALTER TABLE "storage".s3_multipart_uploads OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".s3_multipart_uploads TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE "storage".s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE "storage".s3_multipart_uploads TO anon;


-- "storage".s3_multipart_uploads_parts definição

-- Drop table

-- DROP TABLE "storage".s3_multipart_uploads_parts;

CREATE TABLE "storage".s3_multipart_uploads_parts ( id uuid DEFAULT gen_random_uuid() NOT NULL, upload_id text NOT NULL, "size" int8 DEFAULT 0 NOT NULL, part_number int4 NOT NULL, bucket_id text NOT NULL, "key" text COLLATE "C" NOT NULL, etag text NOT NULL, owner_id text NULL, "version" text NOT NULL, created_at timestamptz DEFAULT now() NOT NULL, CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id), CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES "storage".buckets(id), CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES "storage".s3_multipart_uploads(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE "storage".s3_multipart_uploads_parts OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".s3_multipart_uploads_parts TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE "storage".s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE "storage".s3_multipart_uploads_parts TO anon;


-- "storage".vector_indexes definição

-- Drop table

-- DROP TABLE "storage".vector_indexes;

CREATE TABLE "storage".vector_indexes ( id text DEFAULT gen_random_uuid() NOT NULL, "name" text COLLATE "C" NOT NULL, bucket_id text NOT NULL, data_type text NOT NULL, dimension int4 NOT NULL, distance_metric text NOT NULL, metadata_configuration jsonb NULL, created_at timestamptz DEFAULT now() NOT NULL, updated_at timestamptz DEFAULT now() NOT NULL, CONSTRAINT vector_indexes_pkey PRIMARY KEY (id), CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES "storage".buckets_vectors(id));
CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);

-- Permissions

ALTER TABLE "storage".vector_indexes OWNER TO supabase_storage_admin;
GRANT ALL ON TABLE "storage".vector_indexes TO supabase_storage_admin;
GRANT SELECT ON TABLE "storage".vector_indexes TO service_role;
GRANT SELECT ON TABLE "storage".vector_indexes TO authenticated;
GRANT SELECT ON TABLE "storage".vector_indexes TO anon;



-- DROP FUNCTION "storage".can_insert_object(text, text, uuid, jsonb);

CREATE OR REPLACE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$function$
;

-- Permissions

ALTER FUNCTION "storage".can_insert_object(text, text, uuid, jsonb) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".can_insert_object(text, text, uuid, jsonb) TO supabase_storage_admin;

-- DROP FUNCTION "storage".delete_leaf_prefixes(_text, _text);

CREATE OR REPLACE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".delete_leaf_prefixes(_text, _text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".delete_leaf_prefixes(_text, _text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".enforce_bucket_name_length();

CREATE OR REPLACE FUNCTION storage.enforce_bucket_name_length()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$function$
;

-- Permissions

ALTER FUNCTION "storage".enforce_bucket_name_length() OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".enforce_bucket_name_length() TO supabase_storage_admin;

-- DROP FUNCTION "storage"."extension"(text);

CREATE OR REPLACE FUNCTION storage.extension(name text)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$function$
;

-- Permissions

ALTER FUNCTION "storage"."extension"(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage"."extension"(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".filename(text);

CREATE OR REPLACE FUNCTION storage.filename(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$function$
;

-- Permissions

ALTER FUNCTION "storage".filename(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".filename(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".foldername(text);

CREATE OR REPLACE FUNCTION storage.foldername(name text)
 RETURNS text[]
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$function$
;

-- Permissions

ALTER FUNCTION "storage".foldername(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".foldername(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".get_common_prefix(text, text, text);

CREATE OR REPLACE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".get_common_prefix(text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".get_common_prefix(text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".get_level(text);

CREATE OR REPLACE FUNCTION storage.get_level(name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
SELECT array_length(string_to_array("name", '/'), 1);
$function$
;

-- Permissions

ALTER FUNCTION "storage".get_level(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".get_level(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".get_prefix(text);

CREATE OR REPLACE FUNCTION storage.get_prefix(name text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".get_prefix(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".get_prefix(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".get_prefixes(text);

CREATE OR REPLACE FUNCTION storage.get_prefixes(name text)
 RETURNS text[]
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".get_prefixes(text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".get_prefixes(text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".get_size_by_bucket();

CREATE OR REPLACE FUNCTION storage.get_size_by_bucket()
 RETURNS TABLE(size bigint, bucket_id text)
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$function$
;

-- Permissions

ALTER FUNCTION "storage".get_size_by_bucket() OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".get_size_by_bucket() TO supabase_storage_admin;

-- DROP FUNCTION "storage".list_multipart_uploads_with_delimiter(text, text, text, int4, text, text);

CREATE OR REPLACE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text)
 RETURNS TABLE(key text, id text, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".list_multipart_uploads_with_delimiter(text, text, text, int4, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".list_multipart_uploads_with_delimiter(text, text, text, int4, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".list_objects_with_delimiter(text, text, text, int4, text, text, text);

CREATE OR REPLACE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text)
 RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".list_objects_with_delimiter(text, text, text, int4, text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".list_objects_with_delimiter(text, text, text, int4, text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".operation();

CREATE OR REPLACE FUNCTION storage.operation()
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".operation() OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".operation() TO supabase_storage_admin;

-- DROP FUNCTION "storage".protect_delete();

CREATE OR REPLACE FUNCTION storage.protect_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".protect_delete() OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".protect_delete() TO supabase_storage_admin;

-- DROP FUNCTION "storage"."search"(text, text, int4, int4, int4, text, text, text);

CREATE OR REPLACE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text)
 RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage"."search"(text, text, int4, int4, int4, text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage"."search"(text, text, int4, int4, int4, text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".search_by_timestamp(text, text, int4, int4, text, text, text, text);

CREATE OR REPLACE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text)
 RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".search_by_timestamp(text, text, int4, int4, text, text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".search_by_timestamp(text, text, int4, int4, text, text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".search_legacy_v1(text, text, int4, int4, int4, text, text, text);

CREATE OR REPLACE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text)
 RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$function$
;

-- Permissions

ALTER FUNCTION "storage".search_legacy_v1(text, text, int4, int4, int4, text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".search_legacy_v1(text, text, int4, int4, int4, text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".search_v2(text, text, int4, int4, text, text, text, text);

CREATE OR REPLACE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text)
 RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".search_v2(text, text, int4, int4, text, text, text, text) OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".search_v2(text, text, int4, int4, text, text, text, text) TO supabase_storage_admin;

-- DROP FUNCTION "storage".update_updated_at_column();

CREATE OR REPLACE FUNCTION storage.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$function$
;

-- Permissions

ALTER FUNCTION "storage".update_updated_at_column() OWNER TO supabase_storage_admin;
GRANT ALL ON FUNCTION "storage".update_updated_at_column() TO supabase_storage_admin;


-- Permissions

GRANT ALL ON SCHEMA "storage" TO supabase_admin;
GRANT USAGE ON SCHEMA "storage" TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "storage" TO anon;
GRANT USAGE ON SCHEMA "storage" TO authenticated;
GRANT USAGE ON SCHEMA "storage" TO service_role;
GRANT ALL ON SCHEMA "storage" TO supabase_storage_admin;
GRANT ALL ON SCHEMA "storage" TO dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT MAINTAIN, SELECT, TRUNCATE, INSERT, REFERENCES, DELETE, TRIGGER, UPDATE ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT EXECUTE ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT EXECUTE ON FUNCTIONS TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA "storage" GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO service_role;

-- DROP SCHEMA vault;

CREATE SCHEMA vault AUTHORIZATION supabase_admin;
-- vault.secrets definição

-- Drop table

-- DROP TABLE vault.secrets;

CREATE TABLE vault.secrets ( id uuid DEFAULT gen_random_uuid() NOT NULL, "name" text NULL, description text DEFAULT ''::text NOT NULL, secret text NOT NULL, key_id uuid NULL, nonce bytea DEFAULT vault._crypto_aead_det_noncegen() NULL, created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL, CONSTRAINT secrets_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX secrets_name_idx ON vault.secrets USING btree (name) WHERE (name IS NOT NULL);
COMMENT ON TABLE vault.secrets IS 'Table with encrypted `secret` column for storing sensitive information on disk.';

-- Permissions

ALTER TABLE vault.secrets OWNER TO supabase_admin;
GRANT ALL ON TABLE vault.secrets TO supabase_admin;
GRANT SELECT, TRUNCATE, REFERENCES, DELETE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT, DELETE ON TABLE vault.secrets TO service_role;


-- vault.decrypted_secrets fonte

CREATE OR REPLACE VIEW vault.decrypted_secrets
AS SELECT id,
    name,
    description,
    secret,
    convert_from(vault._crypto_aead_det_decrypt(message => decode(secret, 'base64'::text), additional => convert_to(id::text, 'utf8'::name), key_id => 0::bigint, context => '\x7067736f6469756d'::bytea, nonce => nonce), 'utf8'::name) AS decrypted_secret,
    key_id,
    nonce,
    created_at,
    updated_at
   FROM vault.secrets s;

-- Permissions

ALTER TABLE vault.decrypted_secrets OWNER TO supabase_admin;
GRANT ALL ON TABLE vault.decrypted_secrets TO supabase_admin;
GRANT SELECT, TRUNCATE, REFERENCES, DELETE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT, DELETE ON TABLE vault.decrypted_secrets TO service_role;



-- DROP FUNCTION vault._crypto_aead_det_decrypt(bytea, bytea, int8, bytea, bytea);

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea DEFAULT '\x7067736f6469756d'::bytea, nonce bytea DEFAULT NULL::bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_decrypt_by_id$function$
;

-- Permissions

ALTER FUNCTION vault._crypto_aead_det_decrypt(bytea, bytea, int8, bytea, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(bytea, bytea, int8, bytea, bytea) TO supabase_admin;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(bytea, bytea, int8, bytea, bytea) TO postgres;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(bytea, bytea, int8, bytea, bytea) TO service_role;

-- DROP FUNCTION vault._crypto_aead_det_encrypt(bytea, bytea, int8, bytea, bytea);

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_encrypt(message bytea, additional bytea, key_id bigint, context bytea DEFAULT '\x7067736f6469756d'::bytea, nonce bytea DEFAULT NULL::bytea)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_encrypt_by_id$function$
;

-- Permissions

ALTER FUNCTION vault._crypto_aead_det_encrypt(bytea, bytea, int8, bytea, bytea) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION vault._crypto_aead_det_encrypt(bytea, bytea, int8, bytea, bytea) TO supabase_admin;

-- DROP FUNCTION vault._crypto_aead_det_noncegen();

CREATE OR REPLACE FUNCTION vault._crypto_aead_det_noncegen()
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/supabase_vault', $function$pgsodium_crypto_aead_det_noncegen$function$
;

-- Permissions

ALTER FUNCTION vault._crypto_aead_det_noncegen() OWNER TO supabase_admin;
GRANT ALL ON FUNCTION vault._crypto_aead_det_noncegen() TO supabase_admin;

-- DROP FUNCTION vault.create_secret(text, text, text, uuid);

CREATE OR REPLACE FUNCTION vault.create_secret(new_secret text, new_name text DEFAULT NULL::text, new_description text DEFAULT ''::text, new_key_id uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  rec record;
BEGIN
  INSERT INTO vault.secrets (secret, name, description)
  VALUES (
    new_secret,
    new_name,
    new_description
  )
  RETURNING * INTO rec;
  UPDATE vault.secrets s
  SET secret = encode(vault._crypto_aead_det_encrypt(
    message := convert_to(rec.secret, 'utf8'),
    additional := convert_to(s.id::text, 'utf8'),
    key_id := 0,
    context := 'pgsodium'::bytea,
    nonce := rec.nonce
  ), 'base64')
  WHERE id = rec.id;
  RETURN rec.id;
END
$function$
;

-- Permissions

ALTER FUNCTION vault.create_secret(text, text, text, uuid) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION vault.create_secret(text, text, text, uuid) TO supabase_admin;
GRANT ALL ON FUNCTION vault.create_secret(text, text, text, uuid) TO postgres;
GRANT ALL ON FUNCTION vault.create_secret(text, text, text, uuid) TO service_role;

-- DROP FUNCTION vault.update_secret(uuid, text, text, text, uuid);

CREATE OR REPLACE FUNCTION vault.update_secret(secret_id uuid, new_secret text DEFAULT NULL::text, new_name text DEFAULT NULL::text, new_description text DEFAULT NULL::text, new_key_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  decrypted_secret text := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE id = secret_id);
BEGIN
  UPDATE vault.secrets s
  SET
    secret = CASE WHEN new_secret IS NULL THEN s.secret
                  ELSE encode(vault._crypto_aead_det_encrypt(
                    message := convert_to(new_secret, 'utf8'),
                    additional := convert_to(s.id::text, 'utf8'),
                    key_id := 0,
                    context := 'pgsodium'::bytea,
                    nonce := s.nonce
                  ), 'base64') END,
    name = coalesce(new_name, s.name),
    description = coalesce(new_description, s.description),
    updated_at = now()
  WHERE s.id = secret_id;
END
$function$
;

-- Permissions

ALTER FUNCTION vault.update_secret(uuid, text, text, text, uuid) OWNER TO supabase_admin;
GRANT ALL ON FUNCTION vault.update_secret(uuid, text, text, text, uuid) TO supabase_admin;
GRANT ALL ON FUNCTION vault.update_secret(uuid, text, text, text, uuid) TO postgres;
GRANT ALL ON FUNCTION vault.update_secret(uuid, text, text, text, uuid) TO service_role;


-- Permissions

GRANT ALL ON SCHEMA vault TO supabase_admin;
GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;