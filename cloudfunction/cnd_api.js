const express = require('express');

// Create an Express object and routes (in order)
const app = express();
//app.use('/users/:id', getUser);
app.use('/v2/ipip/', getIpIp);
app.use('/api/iplist/getpinglist/', getPingList);
app.use('/api/iplist/getsdkstatus/', getSdkStatus);
app.use('/api/demo', getDemo);
app.use(getDefault);

// Set our GCF handler to our Express app.
exports.cnd_api = app;

function getIpIp(req, res) {
/**
  bean.setIp(jData.optString("addr"));
  bean.setCityName(jData.optString("city_name"));
  bean.setContinentCode(jData.optString("continent_code"));
  bean.setCountryCode(jData.optString("country_code"));
  bean.setCountryName(jData.optString("country_name"));
  bean.setIspDomain(jData.optString("isp_domain"));
  bean.setLatitude(jData.optString("latitude"));
  bean.setLongitude(jData.optString("longitude"));
  bean.setNetType(jData.optString("net_type"));
  bean.setOwnerDomain(jData.optString("owner_domain"));
  bean.setRegionName(jData.optString("region_name"));
  bean.setTimezone(jData.optString("timezone"));
  bean.setUtcOffset(jData.optString("utc_offset"));
 **/
  res.status(200).send('TBD with GeoIP lib in BQ, getIip');
};

function getPingList(req, res) {
  res.status(200).send('SDK_HAS_BEEN_REGISTERED');
};

function getSdkStatus(req, res) {
    /**
    * 注册模块成功
    REGISTER_SUCCESS,
    * 已注册过SDK
    SDK_HAS_BEEN_REGISTERED,
    * 正在注册SDK中
    SDK_IS_REGISTING,
    * SDK获取授权失败
    OBTAIN_AUTH_FAILED,
    * SDK被远程关闭
    SDK_IS_CLOSED_BY_REMOTE
    **/
  res.status(200).send('SDK_HAS_BEEN_REGISTERED');
};

function getDemo(req, res) {
  let message = req.query.message || req.body.message || 'Hello World!\n';
  res.status(200).send(message);
};

function getDefault(req, res) {
  res.status(403).send();
};

