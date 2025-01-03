/**
 * File for basic authentication to Salesforce
 * @author Rohit Chavan <scorpiorohit311@gmail.com>
 * @created Jan 3, 2025
 * @module src/oauth
 */

import ACCESS_TOKEN_ENDPOINT from './constants';
/**
   * API call for fetching access token
   * @param {requestMap.client_id} - Connected app consumer key
   * @param {requestMap.client_secret} - Connected app consumer secret
   * @param {requestMap.username} - Salesforce username
   * @param {requestMap.password} - Salesforce password
   * @returns - Access token
   */
const fetchAccessToken = async (requestMap) => {
  if (!requestMap) {
    throw Error("Empty request map !");
  }

  const {client_id: clientId, client_secret: clientSecret, username: userName, password} = requestMap;
  let accessToken = "";

  try {
    await fetch(ACCESS_TOKEN_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: new URLSearchParams({
        'grant_type': 'password',
        'client_id': clientId,
        'client_secret': clientSecret,
        'username': userName,
        'password': password
      })
      .toString()
    })
    .then(res => {
      console.log("result", res);
    });
  } catch(error) {
    // handle error
  }

};