-type header() :: {binary(), binary()}.
-type headers() :: [header()].
-type erlastic_json() :: tuple() | list() | map().
%% Hackney async references actually are just that, references... but it seems
%% to be an undocumented implementation detail; doc (and specs) only says `any()'
-type erlastic_success_result() :: erlastic_json() | {async, HackneyRef :: any()}.

-record(erls_params, {
          host        = erls_config:get_host() :: binary(),
          port        = erls_config:get_port() :: integer(),
          
          % URL scheme: <<"https">> (default for ES 8.x+) or <<"http">>
          scheme      = erls_config:get_scheme() :: binary(),
          
          % Authentication credentials (ES 8.x+ has security enabled by default)
          username    = erls_config:get_username() :: binary() | undefined,
          password    = erls_config:get_password() :: binary() | undefined,

          % These are passed verbatim to the underlying http client in use.
          http_client_options = []:: [term()], 

          % Keeping the following two options for backwards compatibility.
          timeout     = infinity :: integer() | infinity,
          ctimeout    = infinity :: integer() | infinity
         }).
