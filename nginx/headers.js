function headers_json_out(r) {
  return JSON.stringify(r.headersOut)
}
function headers_json_in(r) {
  return JSON.stringify(r.headersIn)
}

export default {headers_json_in, headers_json_out};