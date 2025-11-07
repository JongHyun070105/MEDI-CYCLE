export interface Env {
  BACKEND_URL: string;
  ADDRESS_API_KEY: string;
  GEMINI_API_KEY: string;
  EAPIYAK_SERVICE_KEY: string;
  PUBLIC_DATA_API_KEY_DECODED: string;
  KAKAO_REST_API_KEY?: string;
  KAKAO_JS_APP_KEY?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const pathname = url.pathname;

    // CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
      });
    }

    try {
      // Gemini API proxy (new simplified endpoint)
      if (pathname === "/gemini") {
        return handleGeminiProxyV2(request, env);
      }

      // Address search
      if (pathname === "/address-search") {
        return handleAddressSearch(request, env);
      }

      // Address callback
      if (pathname === "/address-callback") {
        return handleAddressCallback(request);
      }

      // Drug search (MFDS DrbEasyDrugInfoService - autocomplete)
      if (pathname === "/drug-search") {
        return handleDrugSearch(request, env);
      }

      // Drug detail (MFDS DrbEasyDrugInfoService - single item)
      if (pathname === "/drug-detail") {
        return handleDrugDetail(request, env);
      }

      // Drug validity (식품의약품안전처_의약품 품목 유효기간 정보)
      if (pathname === "/drug-validity") {
        return handleDrugValidity(request, env);
      }

      // Kakao Local API proxy - keyword place search
      if (pathname === "/kakao/places") {
        return handleKakaoPlaces(request, env);
      }

      // Kakao Local API proxy - reverse geocode (coord2address)
      if (pathname === "/kakao/reverse-geocode") {
        return handleKakaoReverseGeocode(request, env);
      }

      if (pathname === "/kakao/static-map") {
        return handleKakaoStaticMap(request, env);
      }

      // Kakao Map HTML with injected JS APP KEY (served via Worker)
      if (pathname === "/kakao/map.html") {
        return handleKakaoMapHtml(env);
      }

      // Backend proxy for all other routes
      const backendUrl = new URL(
        pathname + url.search,
        env.BACKEND_URL || "http://localhost:3000"
      );

      const headers = new Headers(request.headers);
      headers.set(
        "X-Forwarded-For",
        request.headers.get("CF-Connecting-IP") || "unknown"
      );
      headers.set("X-Forwarded-Proto", "https");

      const proxyRequest = new Request(backendUrl, {
        method: request.method,
        headers,
        body:
          request.method !== "GET" && request.method !== "HEAD"
            ? request.body
            : undefined,
      });

      // simple health check
      if (pathname === "/__health") {
        return new Response(JSON.stringify({ ok: true, ts: Date.now() }), {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        });
      }

      const response = await fetch(proxyRequest);
      const responseText = await response.text();

      const newResponse = new Response(responseText, response);
      newResponse.headers.set("Access-Control-Allow-Origin", "*");
      newResponse.headers.set(
        "Access-Control-Allow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
      );
      newResponse.headers.set(
        "Access-Control-Allow-Headers",
        "Content-Type, Authorization"
      );

      return newResponse;
    } catch (error) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Proxy error",
          error: error instanceof Error ? error.message : "Unknown error",
        }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }
  },
};

// 새로운 Gemini API 핸들러 (서버에서 직접 호출용)
async function handleGeminiProxyV2(
  request: Request,
  env: Env
): Promise<Response> {
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const body = (await request.json()) as any;
    const { systemPrompt, userQuestion } = body;

    if (!systemPrompt || !userQuestion) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Missing systemPrompt or userQuestion",
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";
    const fullUrl = `${geminiUrl}?key=${env.GEMINI_API_KEY}`;

    const response = await fetch(fullUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [
          {
            role: "user",
            parts: [
              {
                text: `${systemPrompt}\n\n사용자 질문: ${userQuestion}`,
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        },
      }),
    });

    const result = (await response.json()) as any;

    if (!response.ok) {
      console.error("Gemini API error:", result);
      return new Response(
        JSON.stringify({
          success: false,
          error: result.error?.message || "Gemini API error",
        }),
        {
          status: response.status,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Gemini 응답 파싱
    if (
      result.candidates &&
      result.candidates[0] &&
      result.candidates[0].content &&
      result.candidates[0].content.parts &&
      result.candidates[0].content.parts[0]
    ) {
      const content = result.candidates[0].content.parts[0].text;
      return new Response(
        JSON.stringify({
          success: true,
          content,
        }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: "No response from Gemini",
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Gemini proxy error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
}

async function handleKakaoStaticMap(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const lat = url.searchParams.get("lat");
  const lng = url.searchParams.get("lng");
  const level = url.searchParams.get("level") || "4";
  const width = url.searchParams.get("w") || "600";
  const height = url.searchParams.get("h") || "400";
  const markers = url.searchParams.getAll("markers");

  if (!lat || !lng) {
    return new Response(
      JSON.stringify({
        success: false,
        message: "lat/lng 파라미터가 필요합니다.",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  if (!env.KAKAO_REST_API_KEY) {
    return new Response("KAKAO_REST_API_KEY is not configured", {
      status: 500,
      headers: { "Content-Type": "text/plain" },
    });
  }

  let markerQuery = "";
  for (const marker of markers) {
    markerQuery += `&markers=${encodeURIComponent(marker)}`;
  }

  const kakaoUrl = `https://dapi.kakao.com/v2/maps/staticmap?map_type=TYPE_MAP&center=${encodeURIComponent(
    `${lng},${lat}`
  )}&level=${encodeURIComponent(level)}&w=${encodeURIComponent(
    width
  )}&h=${encodeURIComponent(height)}${markerQuery}`;

  const response = await fetch(kakaoUrl, {
    headers: {
      Authorization: `KakaoAK ${env.KAKAO_REST_API_KEY}`,
    },
  });

  const arrayBuffer = await response.arrayBuffer();

  return new Response(arrayBuffer, {
    status: response.status,
    headers: {
      "Content-Type": response.headers.get("Content-Type") || "image/png",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "public, max-age=300",
    },
  });
}

async function handleAddressSearch(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const keyword = url.searchParams.get("keyword") || "";
  const currentPage = url.searchParams.get("currentPage") || "1";
  const countPerPage = url.searchParams.get("countPerPage") || "10";

  if (!keyword) {
    return new Response(
      JSON.stringify({
        success: false,
        message: "검색어가 필요합니다.",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  const jusoUrl = `https://business.juso.go.kr/addrlink/addrLinkApi.do?confmKey=${encodeURIComponent(
    env.ADDRESS_API_KEY
  )}&currentPage=${encodeURIComponent(
    currentPage
  )}&countPerPage=${encodeURIComponent(
    countPerPage
  )}&keyword=${encodeURIComponent(keyword)}&resultType=json`;

  try {
    const jusoResponse = await fetch(jusoUrl);
    const jusoData = await jusoResponse.text();

    return new Response(jusoData, {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Cache-Control": "public, max-age=60, stale-while-revalidate=60",
      },
    });
  } catch (jusoError) {
    console.error("공데 API 호출 오류:", jusoError);
    return new Response(
      JSON.stringify({
        success: false,
        message: "주소 검색 중 오류가 발생했습니다.",
        error: jusoError instanceof Error ? jusoError.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

function handleAddressCallback(request: Request): Response {
  const url = new URL(request.url);
  const roadFullAddr = url.searchParams.get("roadFullAddr") || "";
  const roadAddrPart1 = url.searchParams.get("roadAddrPart1") || "";
  const addrDetail = url.searchParams.get("addrDetail") || "";

  const redirectUrl = `about:blank?roadFullAddr=${encodeURIComponent(
    roadFullAddr
  )}&roadAddrPart1=${encodeURIComponent(
    roadAddrPart1
  )}&addrDetail=${encodeURIComponent(addrDetail)}`;

  return new Response(null, {
    status: 302,
    headers: {
      Location: redirectUrl,
      "Access-Control-Allow-Origin": "*",
    },
  });
}

// MFDS 의약품 개요 정보 검색 (자동완성용)
async function handleDrugSearch(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const itemName = url.searchParams.get("itemName") || "";
  const pageNo = url.searchParams.get("pageNo") || "1";
  const numOfRows = url.searchParams.get("numOfRows") || "50";

  if (!itemName) {
    return new Response(
      JSON.stringify({ success: false, message: "itemName is required" }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  const base =
    "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList";
  const fullUrl = `${base}?serviceKey=${encodeURIComponent(
    env.EAPIYAK_SERVICE_KEY
  )}&itemName=${encodeURIComponent(itemName)}&pageNo=${encodeURIComponent(
    pageNo
  )}&numOfRows=${encodeURIComponent(numOfRows)}`;

  try {
    const upstream = await fetch(fullUrl, {
      headers: {
        Accept: "application/xml; charset=utf-8",
        "Content-Type": "application/xml; charset=utf-8",
      },
      // Cloudflare Worker timeout: 30초
      // @ts-expect-error - cf is a Cloudflare Worker specific property
      cf: {
        cacheTtl: 300,
        cacheEverything: false,
      },
    });

    if (!upstream.ok) {
      const errorText = await upstream.text();
      console.error(`Drug search API error: ${upstream.status} - ${errorText}`);
      return new Response(
        JSON.stringify({
          success: false,
          message: "Drug search API error",
          status: upstream.status,
        }),
        {
          status: upstream.status,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        "Content-Type": "application/xml; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=300, stale-while-revalidate=120",
      },
    });
  } catch (error) {
    console.error("Drug search fetch error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: "Drug search error",
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

// MFDS 의약품 단건 상세
async function handleDrugDetail(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const itemName = url.searchParams.get("itemName") || "";

  if (!itemName) {
    return new Response(
      JSON.stringify({ success: false, message: "itemName is required" }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  const base =
    "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList";
  const fullUrl = `${base}?serviceKey=${encodeURIComponent(
    env.EAPIYAK_SERVICE_KEY
  )}&itemName=${encodeURIComponent(itemName)}&numOfRows=1`;

  try {
    const upstream = await fetch(fullUrl, {
      headers: {
        Accept: "application/xml; charset=utf-8",
        "Content-Type": "application/xml; charset=utf-8",
      },
      // Cloudflare Worker timeout: 30초
      // @ts-expect-error - cf is a Cloudflare Worker specific property
      cf: {
        cacheTtl: 300,
        cacheEverything: false,
      },
    });

    if (!upstream.ok) {
      const errorText = await upstream.text();
      console.error(`Drug detail API error: ${upstream.status} - ${errorText}`);
      return new Response(
        JSON.stringify({
          success: false,
          message: "Drug detail API error",
          status: upstream.status,
        }),
        {
          status: upstream.status,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        "Content-Type": "application/xml; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=300, stale-while-revalidate=120",
      },
    });
  } catch (error) {
    console.error("Drug detail fetch error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: "Drug detail error",
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

// 식품의약품안전처_의약품 품목 유효기간 정보 API
async function handleDrugValidity(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const itemName = url.searchParams.get("item_name");
  const entpName = url.searchParams.get("entp_name");
  const pageNo = url.searchParams.get("pageNo") || "1";
  const numOfRows = url.searchParams.get("numOfRows") || "100";

  if (!itemName) {
    return new Response(
      JSON.stringify({ success: false, message: "item_name is required" }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  const base =
    "https://apis.data.go.kr/1471000/DrugPrdlstVldPrdInfoService01/getDrugPrdlstVldPrdInfoService01";
  const params = new URLSearchParams({
    serviceKey: env.PUBLIC_DATA_API_KEY_DECODED,
    type: "json",
    pageNo,
    numOfRows,
    item_name: itemName,
  });
  if (entpName) {
    params.set("entp_name", entpName);
  }

  const fullUrl = `${base}?${params.toString()}`;

  try {
    const upstream = await fetch(fullUrl, {
      headers: {
        Accept: "application/json; charset=utf-8",
        "Content-Type": "application/json; charset=utf-8",
      },
      // @ts-expect-error - cf is a Cloudflare Worker specific property
      cf: {
        cacheTtl: 3600,
        cacheEverything: false,
      },
    });

    if (!upstream.ok) {
      const errorText = await upstream.text();
      console.error(
        `Drug validity API error: ${upstream.status} - ${errorText}`
      );
      return new Response(
        JSON.stringify({
          success: false,
          message: "Drug validity API error",
          status: upstream.status,
        }),
        {
          status: upstream.status,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=3600, stale-while-revalidate=600",
      },
    });
  } catch (error) {
    console.error("Drug validity fetch error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: "Drug validity error",
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

// Kakao Local API: keyword search
async function handleKakaoPlaces(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const query =
    url.searchParams.get("query") || url.searchParams.get("keyword") || "";
  if (!query) {
    return new Response(
      JSON.stringify({ success: false, message: "query is required" }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
  const x = url.searchParams.get("x");
  const y = url.searchParams.get("y");
  const radius = url.searchParams.get("radius");
  const page = url.searchParams.get("page");
  const size = url.searchParams.get("size");
  const category = url.searchParams.get("category_group_code");
  const params = new URLSearchParams({ query });
  if (x) params.set("x", x);
  if (y) params.set("y", y);
  if (radius) params.set("radius", radius);
  if (page) params.set("page", page);
  if (size) params.set("size", size);
  if (category) params.set("category_group_code", category);
  try {
    const upstream = await fetch(
      `https://dapi.kakao.com/v2/local/search/keyword.json?${params.toString()}`,
      {
        headers: { Authorization: `KakaoAK ${env.KAKAO_REST_API_KEY || ""}` },
      }
    );
    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=300, stale-while-revalidate=120",
      },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, message: "Kakao places error" }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

// Kakao Local API: coord2address (reverse geocoding)
async function handleKakaoReverseGeocode(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const x = url.searchParams.get("x");
  const y = url.searchParams.get("y");
  if (!x || !y) {
    return new Response(
      JSON.stringify({ success: false, message: "x and y are required" }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
  const params = new URLSearchParams({ x, y });
  try {
    const upstream = await fetch(
      `https://dapi.kakao.com/v2/local/geo/coord2address.json?${params.toString()}`,
      {
        headers: { Authorization: `KakaoAK ${env.KAKAO_REST_API_KEY || ""}` },
      }
    );
    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=300, stale-while-revalidate=120",
      },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        message: "Kakao reverse geocode error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}

function handleKakaoMapHtml(env: Env): Response {
  const appKey = env.KAKAO_JS_APP_KEY || "";
  const html = `<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script id="kakao-sdk" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${appKey}&libraries=services,clusterer"></script>
    <style>html,body,#map{width:100%;height:100%;margin:0;padding:0}</style>
  </head>
  <body>
    <div id="map"></div>
    <script>
      (function(){
        var map, clusterer, meMarker; var markers=[];
        function init(){
          if(!window.kakao||!window.kakao.maps){setTimeout(init,100);return}
          var center=new kakao.maps.LatLng(37.4979,127.0276);
          map=new kakao.maps.Map(document.getElementById('map'),{center:center,level:4});
          clusterer=new kakao.maps.MarkerClusterer({map:map,averageCenter:true,minLevel:6});
          window.addEventListener('message',function(e){try{var msg=JSON.parse(e.data);
            if(msg.type==='moveTo'&&msg.lat&&msg.lng){map.setCenter(new kakao.maps.LatLng(msg.lat,msg.lng));}
            if(msg.type==='clearMarkers'){markers.forEach(function(m){m.setMap(null)});markers=[];clusterer.clear();}
            if(msg.type==='markers'&&Array.isArray(msg.items)){var newMarkers=msg.items.map(function(it){return new kakao.maps.Marker({position:new kakao.maps.LatLng(it.lat,it.lng),title:it.name||''});});markers=markers.concat(newMarkers);clusterer.addMarkers(newMarkers);} 
            if(msg.type==='setMe'&&msg.lat&&msg.lng){var here=new kakao.maps.LatLng(msg.lat,msg.lng); if(meMarker) meMarker.setMap(null); meMarker=new kakao.maps.Marker({map:map,position:here,title:'현재 위치'}); map.setCenter(here);} 
          }catch(err){}});
        } init();
      })();
    </script>
  </body>
  </html>`;
  return new Response(html, {
    status: 200,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "public, max-age=300",
    },
  });
}
