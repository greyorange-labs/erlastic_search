ErlasticSearch
======================================

An Erlang client for [Elasticsearch](https://www.elastic.co/products/elasticsearch).

**Elasticsearch 9.x Compatible** - This library has been updated to support Elasticsearch 8.x and 9.x, which removed document types and enabled security by default.

Configuration
-------------

Configure the connection in your application environment:

```erlang
%% In sys.config or app.config
{erlastic_search, [
    {host, <<"localhost">>},
    {port, 9200},
    {scheme, <<"https">>},       %% Default: https (ES 8.x+ has security enabled)
    {username, <<"elastic">>},   %% Basic Auth username
    {password, <<"elastic">>}   %% Basic Auth password
]}
```

For local development with security disabled:

```erlang
{erlastic_search, [
    {host, <<"localhost">>},
    {port, 9200},
    {scheme, <<"http">>}
    %% No username/password needed when security is disabled
]}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `host` | binary | `<<"127.0.0.1">>` | Elasticsearch host |
| `port` | integer | `9200` | Elasticsearch port |
| `scheme` | binary | `<<"https">>` | URL scheme (`<<"https">>` or `<<"http">>`) |
| `username` | binary | `undefined` | Basic Auth username |
| `password` | binary | `undefined` | Basic Auth password |

Build and Run
-------------

Start a rebar3 shell:

```shell
rebar3 shell
```

Create an index:

```erlang
erlastic_search:create_index(<<"index_name">>).
```
```
{ok, #{<<"acknowledged">> => true, <<"shards_acknowledged">> => true, <<"index">> => <<"index_name">>}}
```

Index a document:

```erlang
erlastic_search:index_doc(<<"index_name">>, [{<<"key1">>, <<"value1">>}]).
```
```
{ok, #{<<"_index">> => <<"index_name">>,
       <<"_id">> => <<"T-EzM_yeTkOEHPL9cN5B2g">>,
       <<"_version">> => 1,
       <<"result">> => <<"created">>}}
```

Index a document (providing a document id):

```erlang
erlastic_search:index_doc_with_id(<<"index_name">>, <<"id1">>, [{<<"key1">>, <<"value1">>}]).
```
```
{ok, #{<<"_index">> => <<"index_name">>,
       <<"_id">> => <<"id1">>,
       <<"_version">> => 1,
       <<"result">> => <<"created">>}}
```

Search for a document:

```erlang
erlastic_search:search(<<"index_name">>, <<"key1:value1">>).
```
```
{ok, #{<<"took">> => 6,
       <<"timed_out">> => false,
       <<"_shards">> => #{<<"total">> => 1, <<"successful">> => 1, <<"failed">> => 0},
       <<"hits">> => #{
           <<"total">> => #{<<"value">> => 1, <<"relation">> => <<"eq">>},
           <<"max_score">> => 0.30685282,
           <<"hits">> => [
               #{<<"_index">> => <<"index_name">>,
                 <<"_id">> => <<"id1">>,
                 <<"_score">> => 0.30685282,
                 <<"_source">> => #{<<"key1">> => <<"value1">>}}
           ]}}}
```

Bulk indexing:

```erlang
%% Tuple format: {Index, Id, Doc} or {Index, Id, Headers, Doc}
Items = [
    {<<"index_name">>, <<"doc1">>, #{<<"key">> => <<"value1">>}},
    {<<"index_name">>, <<"doc2">>, #{<<"key">> => <<"value2">>}}
],
erlastic_search:bulk_index_docs(Items).
```

Testing
-------

In another terminal use docker-compose to start an Elasticsearch instance:

```bash
docker-compose up
```

For convenience, you can also start a Kibana instance for analysis/visualization:

```bash
docker-compose -f docker-compose.yml -f docker-compose-kibana.yml up
```

Run Common Test:

```bash
rebar3 ct
```

Migration from ES 6.x/7.x
-------------------------

Elasticsearch 8.x removed document types. If you're upgrading from an older version:

**Document Types Removed**
- Old: `erlastic_search:index_doc(Index, Type, Doc)`
- New: `erlastic_search:index_doc(Index, Doc)`

**Bulk Operations**
- Old tuple format: `{Index, Type, Id, Doc}`
- New tuple format: `{Index, Id, Doc}`

**Security Enabled by Default (ES 8.x+)**
- HTTPS is required by default
- Basic Auth with username/password is required
- Configure credentials: `{username, <<"elastic">>}, {password, <<"your_password">>}`
- For local dev with security disabled: `{scheme, <<"http">>}` (no credentials needed)

Using another JSON library than `jsx`
-------------------------------------

By default, we assume all the JSON erlang objects passed to us are in
[`jsx`](https://github.com/talentdeficit/jsx)'s representation.
And similarly, all of Elasticsearch's replies will be decoded with `jsx`.

However, you might already be using another JSON library in your project, which
might encode and decode JSONs from and to a different erlang representation.
For example, [`jiffy`](https://github.com/davisp/jiffy):

```
1> SimpleJson = <<"{\"key\":\"value\"}">>.
<<"{\"key\":\"value\"}">>
```

```
2> jiffy:decode(SimpleJson).
{[{<<"key">>,<<"value">>}]}
```

```
3> jsx:decode(SimpleJson).
[{<<"key">>,<<"value">>}]
```
In that case, you probably want `erlastic_search` to use your JSON
representation of choice instead of `jsx`'s.

You can do so by defining the `ERLASTIC_SEARCH_JSON_MODULE` environment
variable when compiling `erlastic_search`, for example:
```shell
export ERLASTIC_SEARCH_JSON_MODULE=jiffy
rebar compile
```

The only constraint is that `ERLASTIC_SEARCH_JSON_MODULE` should be the name
of a module, in your path, that defines the two following callbacks:

```erlang
-callback encode(erlastic_json()) -> binary().
-callback decode(binary()) -> erlastic_json().
```
where `erlastic_json()` is a type mapping to your JSON representation of choice.

