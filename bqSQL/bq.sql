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


-- LOOKUP IP STRING
WITH test_data AS (
    SELECT '166.111.8.238' AS ip UNION ALL
    SELECT '137.116.146.145' AS ip
)
SELECT ip, city_name, country_name, latitude, longitude
    FROM (
        SELECT ip, NET.SAFE_IP_FROM_STRING(ip) & NET.IP_NET_MASK(4, mask) network_bin, mask
        FROM test_data, UNNEST(GENERATE_ARRAY(8,32)) mask
    )
    JOIN `geoip_lite.cityLoc4bin`
    USING (network_bin, mask);


