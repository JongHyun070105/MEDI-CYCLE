export interface Env {
  BACKEND_URL: string;
  ADDRESS_API_KEY: string;
  GEMINI_API_KEY: string;
  EAPIYAK_SERVICE_KEY: string;
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

async function handleAddressSearch(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const keyword = url.searchParams.get("keyword") || "";

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

  const jusoUrl = `https://business.juso.go.kr/addrlink/addrLinkApi.do?confmKey=${
    env.ADDRESS_API_KEY
  }&keyword=${encodeURIComponent(keyword)}&resultType=json`;

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
