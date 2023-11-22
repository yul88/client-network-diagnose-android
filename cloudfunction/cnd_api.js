const express = require('express')
const geoip = require('fast-geoip')
const {GoogleAuth} = require('google-auth-library')
const morgan = require('morgan')


// Create an Express object and routes (in order)
const app = express()
app.use(morgan('combined'))

app.get('/api/demo', getDemo)
app.get('/v1/ipip', getIpIp)
app.get('/api/getToken', getToken)
app.post('/api/iplist/getpinglist/', getPingList)
app.post('/api/iplist/getsdkstatus/', getSdkStatus)
app.post('/api/report/', getReport)
app.use(getDefault)

// Set our GCF handler to our Express app.
exports.cnd_api = app

function getDemo(req, res) {
    let message = req.query.message || req.body.message || 'Hello World!\n'
    res.status(200).send(message)
}

async function getIpIp(req, res) {
    var ip = req.headers['x-forwarded-for']?.split(',').shift() || req.socket?.remoteAddress
    var geo = await geoip.lookup(ip)

    res.status(200).send({
        "meta":{
            "ret": 200,
            "error": ""
        },
        "data": {
            "addr": ip,
            "city_name": geo.city,
            "continent_code": "",
            "country_code": geo.country,
            "country_name": "",
            "isp_domain": "",
            "latitude": geo.ll[0],
            "longitude": geo.ll[1],
            "net_type": "",
            "owner_domain": "",
            "region_name": geo.region,
            "timezone": geo.timezone,
            "utc_offset": ""
        }
    })
}

async function getToken(req, res) {
    const auth = new GoogleAuth()
    let token = await auth.getAccessToken()

    console.log(token)
    res.status(200).send({
        "meta":{
            "code": 200,
            "error": ""
        },
        "data": {
            "enabled": 1,
            "token": token
        }
    })
}

function getPingList(req, res) {
    let projectId = '<Your GCP Project ID>'
    let topicId = '<Your Pub/Sub Topic ID>'
    let pubUrl = `https://pubsub.googleapis.com/v1/projects/${projectId}/topics/${topicId}:publish`
    // 这里指定了2个IP 8.8.8.8 和 8.8.4.4 用于探测，最多可以加到5个IP
    res.status(200).send({
        "meta":{
            "code": 200,
            "error": ""
        },
        "data": {
            "domain": "cloud.google.com",
            "url": [pubUrl],
            "info": [
                {
                    "ip": "8.8.8.8",
                    "location": "global1",
                    "type": 0,
                    "id": 1
                },
                {
                    "ip": "8.8.4.4",
                    "location": "global2",
                    "type": 0,
                    "id": 2
                }
            ]
        }
    })
}

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
    // 实际业务中应该加入业务判断，对何种Client继续进行CND诊断
    res.status(200).send({
        "meta":{
            "code": 200,
            "error": ""
        },
        "data": {"enabled": 1}
    })
}

function getReport(req, res) {
    res.status(200).send({
        "meta":{
            "code": 200,
            "error": ""
        },
        "data": {
            "enabled": 1,
            "req_body": req.body
        }
    })
    console.log(req.body)
}

function getDefault(req, res) {
    res.status(403).send()
}

