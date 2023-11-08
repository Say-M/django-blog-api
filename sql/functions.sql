DROP FUNCTION IF EXISTS create_user;
CREATE OR REPLACE FUNCTION create_user(data JSON)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
	_username VARCHAR = coalesce((data->>'username')::varchar, NULL);
	_firstName VARCHAR = coalesce((data->>'firstName')::varchar, NULL);
	_lastName VARCHAR = coalesce((data->>'lastName')::varchar, NULL);
	_email VARCHAR = coalesce((data->>'email')::varchar, NULL);
	_password VARCHAR = coalesce((data->>'password')::varchar, NULL);
	_bio VARCHAR = coalesce((data->>'bio')::varchar, NULL);
BEGIN
	-- check if all required variables are available or not
	IF _username IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'username', 'required'
		);
	END IF;
	IF _firstname IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'firstName', 'required'
		);
	END IF;
	IF _lastname IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'lastName', 'required'
		);
	END IF;
	IF _email IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'email', 'required'
		);
	END IF;
	IF _password IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'password', 'required'
		);
	END IF;
	
	INSERT INTO users (username, "firstName", "lastName", email, password, bio)
	VALUES (_username, _firstName, _lastName, _email, _password, _bio)
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'username', username,
		'firstName', "firstName",
		'lastName', "lastName",
		'email', email,
		'bio', bio
	) INTO _user;
	
	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_users;
CREATE OR REPLACE FUNCTION get_users(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
	_users JSON = NULL::JSON;
	_page INT = coalesce(_page, 1);
	_limit INT = coalesce(_limit, 10);
BEGIN
	_users = (
		SELECT JSON_AGG(u) 
		FROM (
			SELECT id, username, "firstName", "lastName", email, bio
			FROM users
			ORDER BY id ASC
			LIMIT _limit
			OFFSET (_page - 1) * _limit
		) u
	)::JSON;
	
	RETURN JSON_BUILD_OBJECT(
		'status', 'success',
		'users', _users
	);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS get_user;
CREATE OR REPLACE FUNCTION get_user(_id INT)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
BEGIN
	-- check if all required variables are available or not
	IF _id IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'id', 'required'
		);
	END IF;
	
	_user = (
		SELECT JSON_AGG(u) 
		FROM users u
		WHERE id = _id
	)::JSON -> 0;
	
	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS update_user;
CREATE OR REPLACE FUNCTION update_user(_id INT, data JSON)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
	_username VARCHAR = coalesce((data->>'username')::varchar, NULL);
	_firstName VARCHAR = coalesce((data->>'firstName')::varchar, NULL);
	_lastName VARCHAR = coalesce((data->>'lastName')::varchar, NULL);
	_email VARCHAR = coalesce((data->>'email')::varchar, NULL);
	_password VARCHAR = coalesce((data->>'password')::varchar, NULL);
	_bio VARCHAR = coalesce((data->>'bio')::varchar, NULL);
BEGIN
	-- check if all required variables are available or not
	IF _id IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'id', 'required'
		);
	END IF;
	
	UPDATE users
	SET
		username = coalesce(_username, username),
		"firstName" = coalesce(_firstName, "firstName"),
		"lastName" = coalesce(_lastName, "lastName"),
		email = coalesce(_email, email),
		password = coalesce(_password, password),
		bio = coalesce(_bio, bio)
	WHERE id = _id
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'username', username,
		'firstName', "firstName",
		'lastName', "lastName",
		'email', email,
		'bio', bio
	) INTO _user;
	
	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS delete_user;
CREATE OR REPLACE FUNCTION delete_user(_id INT)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
BEGIN
	-- check if all required variables are available or not
	IF _id IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'id', 'required'
		);
	END IF;
	
	DELETE FROM users
	WHERE id = _id
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'username', username,
		'firstName', "firstName",
		'lastName', "lastName",
		'email', email,
		'bio', bio
	) INTO _user;
	
	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

