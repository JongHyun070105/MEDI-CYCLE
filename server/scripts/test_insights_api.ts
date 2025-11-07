import axios from 'axios';

async function testInsightsApi() {
  try {
    // 1. 로그인하여 토큰 획득
    console.log('🔐 로그인 중...');
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'cha@gmail.com',
      password: 'password'
    });
    
    const token = loginResponse.data.token;
    console.log('✅ 로그인 성공');
    
    // 2. 인사이트 API 호출
    console.log('\n📊 인사이트 API 호출 중...');
    const insightsResponse = await axios.get('http://localhost:3000/api/medications/stats/insights', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('\n📈 인사이트 API 응답:');
    console.log(JSON.stringify(insightsResponse.data, null, 2));
    
  } catch (error: any) {
    console.error('❌ 오류 발생:', error.response?.data || error.message);
  }
}

testInsightsApi();

