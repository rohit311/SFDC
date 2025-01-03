/**
 * File for Bulk API 2.0
 * @author Rohit Chavan <scorpiorohit311@gmail.com>
 * @created Jan 3, 2025
 * @module src
 */


const createQueryJob = async (instanceUrl, query) => {
  if (!instanceUrl || !query) {
    throw new Error("Empty instance url or query !");
  }

  try {

    const result = fetch(`${instanceUrl}/services/data/v62.0/jobs/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: JSON.stringify({
        "operation": "query",
          query
      })
    });

    const response = (await result).json();

    return response;

  } catch(error) {
    // handle error
    console.log("error:", error);
  }
};