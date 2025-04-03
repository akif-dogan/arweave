%% This Source Code Form is subject to the terms of the GNU General
%% Public License, v. 2.0. If a copy of the GPLv2 was not distributed
%% with this file, You can obtain one at
%% https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

-module(big_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-include_lib("bigfile/include/big.hrl").
-include_lib("bigfile/include/big_sup.hrl").
-include_lib("bigfile/include/big_config.hrl").

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	%% These ETS tables should belong to the supervisor.
	ets:new(big_peers, [set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_http, [set, public, named_table]),
	ets:new(big_blacklist_middleware, [set, public, named_table]),
	ets:new(blacklist, [set, public, named_table]),
	ets:new(ignored_ids, [bag, public, named_table]),
	ets:new(ar_tx_emitter_recently_emitted, [set, public, named_table]),
	ets:new(ar_tx_db, [set, public, named_table]),
	ets:new(ar_packing_server, [set, public, named_table]),
	ets:new(replica_2_9_entropy_cache, [set, public, named_table]),
	ets:new(replica_2_9_entropy_cache_ordered_keys, [ordered_set, public, named_table]),
	ets:new(ar_nonce_limiter, [set, public, named_table]),
	ets:new(ar_nonce_limiter_server, [set, public, named_table]),
	ets:new(big_header_sync, [set, public, named_table, {read_concurrency, true}]),
	ets:new(big_data_discovery, [ordered_set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_data_sync_worker_master, [set, public, named_table]),
	ets:new(ar_data_sync_state, [set, public, named_table, {read_concurrency, true}]),
	ets:new(big_chunk_storage, [set, public, named_table]),
	ets:new(ar_entropy_storage, [set, public, named_table]),
	ets:new(ar_mining_stats, [set, public, named_table]),
	ets:new(ar_global_sync_record, [set, public, named_table]),
	ets:new(ar_disk_pool_data_roots, [set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_tx_blacklist, [set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_tx_blacklist_pending_headers,
			[set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_tx_blacklist_pending_data,
			[set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_tx_blacklist_offsets,
			[ordered_set, public, named_table, {read_concurrency, true}]),
	ets:new(ar_tx_blacklist_pending_restore_headers,
			[ordered_set, public, named_table, {read_concurrency, true}]),
	ets:new(block_cache, [set, public, named_table]),
	ets:new(tx_prefixes, [bag, public, named_table]),
	ets:new(block_index, [ordered_set, public, named_table]),
	ets:new(node_state, [set, public, named_table]),
	ets:new(mining_state, [set, public, named_table, {read_concurrency, true}]),
	Children = [
		?CHILD(ar_rate_limiter, worker),
		?CHILD(ar_disksup, worker),
		?CHILD_SUP(ar_events_sup, supervisor),
		?CHILD_SUP(ar_http_sup, supervisor),
		?CHILD_SUP(ar_kv_sup, supervisor),
		?CHILD_SUP(big_storage_sup, supervisor),
		?CHILD(big_peers, worker),
		?CHILD(ar_disk_cache, worker),
		?CHILD(ar_watchdog, worker),
		?CHILD(ar_tx_blacklist, worker),
		?CHILD_SUP(ar_bridge_sup, supervisor),
		?CHILD(ar_packing_server, worker),
		?CHILD_SUP(ar_sync_record_sup, supervisor),
		?CHILD(big_data_discovery, worker),
		?CHILD(big_header_sync, worker),
		?CHILD_SUP(ar_data_sync_sup, supervisor),
		?CHILD_SUP(ar_chunk_storage_sup, supervisor),
		?CHILD_SUP(big_verify_chunks_sup, supervisor),
		?CHILD(ar_global_sync_record, worker),
		?CHILD_SUP(ar_nonce_limiter_sup, supervisor),
		?CHILD_SUP(ar_mining_sup, supervisor),
		?CHILD(ar_coordination, worker),
		?CHILD_SUP(ar_tx_emitter_sup, supervisor),
		?CHILD(ar_tx_poller, worker),
		?CHILD_SUP(ar_block_pre_validator_sup, supervisor),
		?CHILD_SUP(ar_poller_sup, supervisor),
		?CHILD_SUP(ar_node_sup, supervisor),
		?CHILD_SUP(big_webhook_sup, supervisor),
		?CHILD(big_p3, worker),
		?CHILD(ar_p3_db, worker),
		?CHILD(big_pool, worker),
		?CHILD(ar_pool_job_poller, worker),
		?CHILD(ar_pool_cm_job_poller, worker),
		?CHILD(big_chain_stats, worker)
	],
	{ok, Config} = application:get_env(bigfile, config),
	DebugChildren = case Config#config.debug of
		true -> [?CHILD(ar_process_sampler, worker)];
		false -> []
	end,
	{ok, {{one_for_one, 5, 10}, Children ++ DebugChildren}}.
