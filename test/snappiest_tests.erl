%% Copyright 2011,  Filipe David Manana  <fdmanana@apache.org>
%% Web:  http://github.com/fdmanana/snappy-erlang-nif
%%
%% Licensed under the Apache License, Version 2.0 (the "License"); you may not
%% use this file except in compliance with the License. You may obtain a copy of
%% the License at
%%
%%  http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
%% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
%% License for the specific language governing permissions and limitations under
%% the License.

-module(snappiest_tests).
-include_lib("eunit/include/eunit.hrl").


compression_test_() ->
    {timeout, 60, [fun compression/0]}.

decompression_test_() ->
    {timeout, 60, [fun decompression/0]}.


compression() ->
    DataIoList =
      lists:duplicate(11, <<"words that go unspoken, deeds that go undone">>),
    Data = iolist_to_binary(DataIoList),
    Result = snappiest:compress(Data),
    ?assertMatch({ok, _}, Result),
    {ok, Compressed} = Result,

    ?assertEqual(true, byte_size(Compressed) < byte_size(Data)),

    ?assertEqual(true, snappiest:is_valid(Compressed)),
    ?assertEqual(false, snappiest:is_valid(Data)),
    ?assertEqual(false, snappiest:is_valid(<<"foobar123">>)),
    ?assertEqual({ok, byte_size(Data)},
                 snappiest:uncompressed_length(Compressed)),

    Result2 = snappiest:compress(DataIoList),
    ?assertMatch({ok, _}, Result2),
    {ok, Compressed2} = Result2,

    ?assertEqual(byte_size(Compressed2), byte_size(Compressed)),
    ?assertEqual(true, snappiest:is_valid(Compressed2)),
    ?assertEqual({ok, byte_size(Data)},
                 snappiest:uncompressed_length(Compressed2)),
    ok.


decompression() ->
    DataIoList =
      lists:duplicate(11, <<"words that go unspoken, deeds that go undone">>),
    Data = iolist_to_binary(DataIoList),
    Result = snappiest:compress(Data),
    ?assertMatch({ok, _}, Result),
    {ok, Compressed} = Result,
    ?assertEqual({ok, Data}, snappiest:decompress(Compressed)),

    Result2 = snappiest:compress(DataIoList),
    ?assertMatch({ok, _}, Result2),
    {ok, Compressed2} = Result2,
    ?assertEqual({ok, Data}, snappiest:decompress(Compressed2)),

    BigData = <<"mVPZzfDzKNeZrh1QdkMEgh2U0Bv2i3+bLJaCqgNibXuMuwfjrqTuxPGupxjI",
                "xEbuYR+u/KZvSDhoxnkpPbgJo7oiQv2ibDrrGZx7RDs3Nn7Ww51B7+zUL4tr",
                "G+16TlJilJT47Z4cQn8EpWex2bMRFAoJ6AMJAodLGbiD78yUyIorRKVcCa+k",
                "udzjsqYAoXzW/z8JCB6rbGGSbnLyqztR//ch5sRwSvYARlV+IamzBkDXFZxj",
                "5TAwAl2ZcbCeMX0qgXX4EonVZxc=">>,
    Result3 = snappiest:compress(BigData),
    ?assertMatch({ok, _}, Result3),
    {ok, Compressed3} = Result3,
    ?assertEqual({ok, BigData}, snappiest:decompress(Compressed3)),
    ok.

check_double_decompress_doesnt_cause_segault_test() ->
    % Try to decompress an empty binary
    ?assertMatch({ok,<<>>}, snappiest:decompress(<<>>)),
    % And once more...
    ?assertMatch({ok,<<>>}, snappiest:decompress(<<>>)),
    ok.

check_double_compress_doesnt_cause_segault_test() ->
    % Try to compress an empty binary
    ?assertMatch({ok,<<>>},snappiest:compress(<<>>)),
    % And once more...
    ?assertMatch({ok,<<>>},snappiest:compress(<<>>)),
    ok.

can_compress_and_decompress_empty_binary_test() ->
    % Try to compress an empty binary...
    {ok, Compressed} = snappiest:compress(<<>>),
    % Try to decompress the result of the compression...
    {ok, _Decompressed} = snappiest:decompress(Compressed),
    ok.

can_compress_an_empty_binary_test() ->
    % Try to compress an empty binary...
    {ok, Compressed} = snappiest:compress(<<>>),
    % Check an empty binary was returned
    ?assertMatch(Compressed,<<>>),
    ok.

can_decompress_an_empty_binary_test() ->
    % Try to decompress an empty binary
    {ok, Decompressed} = snappiest:decompress(<<>>),
    ?assertMatch(Decompressed,<<>>),
    ok.
