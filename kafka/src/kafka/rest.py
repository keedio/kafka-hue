#!/usr/bin/env python
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http:# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import urllib2
import simplejson


class ZooKeeper(object):
    """ Zoookeeper Class """

    class Error(Exception): 
        pass

    class NotFound(Error): 
        pass

    class RESTError(Error):
        pass

    def __init__(self, uri='http://localhost:9998'):
        self._base = uri
        try:
            self.get("/")
        except ZooKeeper.NotFound:
            raise ZooKeeper.RESTError

    def get(self, path):
        """ Get a node """
        url = "%s/znodes/v1%s" % (self._base, path)
        return self._do_get(url)

    def get_children(self, path):
        """ Get all the children for a given path. This function creates a generator """
        for child_path in self.get_children_paths(path, uris=True):
            try:
                yield self._do_get(child_path)
            except ZooKeeper.NotFound:
                continue

    def get_children_paths(self, path, uris=False):
        """ Get the paths for children nodes """
        url = "%s/znodes/v1%s?view=children" % (self._base, path)
        try:
            resp = self._do_get(url)
            for child in resp.get('children', []):
                yield child if not uris else resp['child_uri_template']\
                  .replace('{child}', urllib2.quote(child))
        
        except ZooKeeper.NotFound:
            raise


    def _do_get(self, uri):
        """ Send a GET request and convert errors to exceptions """
        try:
            req = urllib2.urlopen(uri)
            resp = simplejson.load(req)

            if 'Error' in resp:
                raise ZooKeeper.Error(resp['Error'])

            return resp
        except urllib2.URLError:
            raise ZooKeeper.NotFound(uri)

        except urllib2.HTTPError, e:
            if e.code == 404:
                raise ZooKeeper.NotFound(uri)
            raise

