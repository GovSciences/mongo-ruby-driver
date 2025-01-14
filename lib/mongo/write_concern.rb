# Copyright (C) 2015-2019 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'mongo/write_concern/base'
require 'mongo/write_concern/acknowledged'
require 'mongo/write_concern/unacknowledged'

module Mongo

  # Base module for all write concern specific behavior.
  #
  # @since 2.0.0
  module WriteConcern
    extend self

    # The number of servers write concern.
    #
    # @since 2.0.0
    W = :w.freeze

    # The journal write concern.
    #
    # @since 2.0.0
    J = :j.freeze

    # The file sync write concern.
    #
    # @since 2.0.0
    FSYNC = :fsync.freeze

    # The wtimeout write concern.
    #
    # @since 2.0.0
    WTIMEOUT = :wtimeout.freeze

    # The GLE command name.
    #
    # @since 2.0.0
    GET_LAST_ERROR = :getlasterror.freeze

    # The default write concern is to acknowledge on a single server.
    #
    # @since 2.0.0
    DEFAULT = { }.freeze

    # Create a write concern object for the provided options.
    #
    # @example Get a write concern.
    #   Mongo::WriteConcern.get(:w => 1)
    #
    # @param [ Hash ] options The options to instantiate with.
    #
    # @option options :w [ Integer, String ] The number of servers or the
    #   custom mode to acknowledge.
    # @option options :j [ true, false ] Whether to acknowledge a write to
    #   the journal.
    # @option options :fsync [ true, false ] Should the write be synced to
    #   disc.
    # @option options :wtimeout [ Integer ] The number of milliseconds to
    #   wait for acknowledgement before raising an error.
    #
    # @return [ Unacknowledged, Acknowledged ] The appropriate concern.
    #
    # @raise [ Error::InvalidWriteConcern ] If the options are invalid.
    #
    # @since 2.0.0
    def get(options)
      return options if options.is_a?(Base)
      if options
        validate!(options)
        if (options[:w] || options['w']) == 0
          Unacknowledged.new(options)
        else
          Acknowledged.new(options)
        end
      end
    end

    private

    def validate!(options)
      if options[W]
        if options[W] == 0 && (options[J] || options[FSYNC])
          raise Mongo::Error::InvalidWriteConcern.new
        elsif options[W].is_a?(Integer) && options[W] < 0
          raise Mongo::Error::InvalidWriteConcern.new
        end
      end
    end
  end
end
