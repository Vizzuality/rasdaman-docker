-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
-- This file is part of rasdaman community.
--
-- Rasdaman community is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Rasdaman community is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with rasdaman community.  If not, see <http://www.gnu.org/licenses/>.
--
-- Copyright 2003, 2004, 2005, 2006, 2007, 2008, 2009 Peter Baumann /
-- rasdaman GmbH.
--
-- For more information please see <http://www.rasdaman.org>
-- or contact Peter Baumann via <baumann@rasdaman.com>.
-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=

-------------------------------------------------------------------------------------
-- ows:Role has values taken from Subclause B.5.5 of ISO 19115:2003. (ticket #720) --
-- @see http://schemas.opengis.net/ows/2.0/ows19115subset.xsd                      --
-- @see http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml           --
-------------------------------------------------------------------------------------
-- create
CREATE TABLE ps_role_code (
   id          serial   PRIMARY KEY,
   value       text     NOT NULL,
   description text     NULL,
   -- Constraints and FKs
   UNIQUE (value)
);
-- populate
INSERT INTO ps_role_code (value, description) VALUES (
  'resourceProvider',
  'party that supplies the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'custodian',
  'party that accepts accountability and responsability for the data and ensures appropriate care and maintenance of the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'owner',
  'party that owns the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'user',
  'party who uses the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'distributor',
  'party who distributes the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'originator',
  'party who created the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'pointOfContact',
  'party who can be contacted for acquiring knowledge about or acquisition of the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'principalInvestigator',
  'key party responsible for gathering information and conducting research');
INSERT INTO ps_role_code (value, description) VALUES (
  'processor',
  'party who has processed the data in a manner such that the resource has been modified');
INSERT INTO ps_role_code (value, description) VALUES (
  'publisher',
  'party who published the resource');
INSERT INTO ps_role_code (value, description) VALUES (
  'author',
  'party who authored the resource');
-- alter
UPDATE ps_service_provider SET contact_role=NULL;
ALTER TABLE ps_service_provider ALTER  COLUMN contact_role SET DATA TYPE integer USING contact_role::integer;
ALTER TABLE ps_service_provider RENAME COLUMN contact_role TO contact_role_id;
ALTER TABLE ps_service_provider ADD FOREIGN KEY (contact_role_id) REFERENCES ps_role_code (id) ON DELETE RESTRICT;
UPDATE ps_service_provider SET contact_position_name='Data Scientist', contact_role_id=( SELECT id FROM ps_role_code WHERE value='pointOfContact');
