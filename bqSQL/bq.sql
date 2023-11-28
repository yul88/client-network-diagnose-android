-- LOAD GEPIP CSV
LOAD DATA OVERWRITE geoip_lite.GeoLite2-ASN-Blocks-IPv4
FROM FILES (
      format = 'CSV',
      uris = ['gs://bucket/path/GeoLite2-ASN-Blocks-IPv4.csv']);

LOAD DATA OVERWRITE geoip_lite.GeoLite2-ASN-Blocks-IPv6
FROM FILES (
      format = 'CSV',
      uris = ['gs://bucket/path/GeoLite2-ASN-Blocks-IPv6.csv']);

LOAD DATA OVERWRITE geoip_lite.GeoLite2-City-Blocks-IPv4
FROM FILES (
      format = 'CSV',
      uris = ['gs://bucket/path/GeoLite2-City-Blocks-IPv4.csv']);

LOAD DATA OVERWRITE geoip_lite.GeoLite2-City-Blocks-IPv6
FROM FILES (
      format = 'CSV',
      uris = ['gs://bucket/path/GeoLite2-City-Blocks-IPv6.csv']);

LOAD DATA OVERWRITE geoip_lite.GeoLite2-City-Locations-en
FROM FILES (
      format = 'CSV',
      uris = ['gs://bucket/path/GeoLite2-City-Locations-en.csv']);


-- REPLACE geoname_id WITH Location
CREATE TABLE cityLoc4
AS
SELECT network, city_name, country_name, latitude, longitude
FROM `geoip_lite.GeoLite2-City-Blocks-IPv4` ipv4 LEFT JOIN `geoip_lite.GeoLite2-City-Locations-en` locen
ON (ipv4.geoname_id IS NOT NULL AND ipv4.geoname_id = locen.geoname_id) OR (ipv4.geoname_id IS NULL AND ipv4.registered_country_geoname_id = locen.geoname_id);


-- REPLACE IP STRING to BIN for lookup
CREATE TABLE `geoip_lite.cityLoc4bin`
AS
SELECT
  NET.IP_FROM_STRING(REGEXP_EXTRACT(network, r'(.*)/' )) network_bin,
  CAST(REGEXP_EXTRACT(network, r'/(.*)' ) AS INT64) mask,
  city_name, country_name, latitude, longitude
FROM geoip_lite.cityLoc4;

CREATE TABLE `geoip_lite.asnBlock4bin`
AS
SELECT
  NET.IP_FROM_STRING(REGEXP_EXTRACT(network, r'(.*)/' )) network_bin,
  CAST(REGEXP_EXTRACT(network, r'/(.*)' ) AS INT64) mask,
  autonomous_system_number, autonomous_system_organization
FROM geoip_lite.GeoLite2-ASN-Blocks-IPv4;

-- LOOKUP IP STRING
WITH ipbin AS (
    SELECT ip, NET.SAFE_IP_FROM_STRING(ip) & NET.IP_NET_MASK(4, mask) network_bin, mask
        FROM (
            SELECT '1.1.1.1' AS ip UNION ALL
            SELECT '8.8.8.8' AS ip UNION ALL
            SELECT '9.9.9.9' AS ip UNION ALL
            SELECT '114.114.114.114' AS ip UNION ALL
            SELECT '119.29.29.29' AS ip UNION ALL
            SELECT '223.5.5.5' AS ip
    ), UNNEST(GENERATE_ARRAY(8,32)) mask
)
SELECT ip, autonomous_system_organization, city_name, country_name, latitude, longitude
FROM (
    SELECT ip, city_name, country_name, latitude, longitude
        FROM ipbin
        JOIN `geoip_lite.cityLoc4bin`
        USING (network_bin, mask)
    ) ipcity JOIN (
    SELECT ip, autonomous_system_organization
        FROM ipbin
        JOIN `geoip_lite.asnBlock4bin`
        USING (network_bin, mask)
    ) ipasn
USING (ip);

