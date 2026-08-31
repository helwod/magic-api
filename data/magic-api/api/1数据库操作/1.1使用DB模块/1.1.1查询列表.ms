{
  "properties" : { },
  "id" : "0d4c0aa7f7b44072a820c88cb932662f",
  "script" : null,
  "groupId" : "8350c5f638d9400fa9c44f46412bba31",
  "name" : "1.1.1查询列表",
  "createTime" : 1787823279213,
  "updateTime" : 1787904037181,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/list",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ {
    "name" : "default_data_source",
    "value" : "",
    "description" : "配置默认数据源的key",
    "required" : false,
    "dataType" : "String",
    "type" : null,
    "defaultValue" : null,
    "validateType" : null,
    "error" : null,
    "expression" : null,
    "children" : null
  } ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": -1,\n    \"message\": \"系统内部出现错误\",\n    \"data\": null,\n    \"timestamp\": 1787888284553,\n    \"executeTime\": 28\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
// 相关API：https://www.ssssssss.org/magic-api/pages/module/db/#%E5%8D%95%E8%A1%A8%E6%93%8D%E4%BD%9Capi

// return db.mysql.select('select * from user');   //成功调用

return db.mysql.table('user')
        .column('User') // 只查询api_name列
        .select()