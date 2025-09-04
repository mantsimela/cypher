import React, { useState, useEffect } from 'react';
import Content from "@/layout/content/Content";
import Head from "@/layout/head/Head";
import { 
  Block, 
  BlockHead, 
  BlockHeadContent, 
  BlockTitle, 
  Button, 
  Icon,
  Row,
  Col
} from "@/components/Component";
import { buildApiUrl } from '../config/api.js';

const TestPage = () => {
  const [tests, setTests] = useState({
    frontend: { status: 'loading', message: 'Testing...' },
    apiConfig: { status: 'loading', message: 'Testing...' },
    backendHealth: { status: 'loading', message: 'Testing...' },
    authentication: { status: 'loading', message: 'Testing...' }
  });

  useEffect(() => {
    runTests();
  }, []);

  const runTests = async () => {
    // Test 1: Frontend Loading
    setTests(prev => ({
      ...prev,
      frontend: { status: 'success', message: 'React application loaded successfully' }
    }));

    // Test 2: API Configuration
    try {
      const apiUrl = buildApiUrl('/health');
      setTests(prev => ({
        ...prev,
        apiConfig: { 
          status: 'success', 
          message: `API URL correctly configured: ${apiUrl}` 
        }
      }));
    } catch (error) {
      setTests(prev => ({
        ...prev,
        apiConfig: { 
          status: 'error', 
          message: `API configuration error: ${error.message}` 
        }
      }));
    }

    // Test 3: Backend Health Check
    try {
      const healthUrl = buildApiUrl('/health');
      const response = await fetch(healthUrl);
      const data = await response.json();
      
      if (data.status === 'OK') {
        setTests(prev => ({
          ...prev,
          backendHealth: { 
            status: 'success', 
            message: `Backend API healthy: ${data.message} (v${data.version})` 
          }
        }));
      } else {
        setTests(prev => ({
          ...prev,
          backendHealth: { 
            status: 'warning', 
            message: 'Backend responded but status not OK' 
          }
        }));
      }
    } catch (error) {
      setTests(prev => ({
        ...prev,
        backendHealth: { 
          status: 'error', 
          message: `Backend health check failed: ${error.message}` 
        }
      }));
    }

    // Test 4: Authentication Endpoint
    try {
      const authUrl = buildApiUrl('/auth/validate');
      const response = await fetch(authUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      // We expect this to fail without a token, but a 401 response means the endpoint is working
      if (response.status === 401) {
        setTests(prev => ({
          ...prev,
          authentication: { 
            status: 'success', 
            message: 'Authentication endpoint responding correctly (401 as expected)' 
          }
        }));
      } else if (response.status === 200) {
        setTests(prev => ({
          ...prev,
          authentication: { 
            status: 'success', 
            message: 'Authentication endpoint responding (200 - possibly authenticated)' 
          }
        }));
      } else {
        setTests(prev => ({
          ...prev,
          authentication: { 
            status: 'warning', 
            message: `Authentication endpoint returned status: ${response.status}` 
          }
        }));
      }
    } catch (error) {
      setTests(prev => ({
        ...prev,
        authentication: { 
          status: 'error', 
          message: `Authentication test failed: ${error.message}` 
        }
      }));
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'success': return 'check-circle';
      case 'warning': return 'alert-triangle';
      case 'error': return 'cross-circle';
      default: return 'loader';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'success': return 'success';
      case 'warning': return 'warning';
      case 'error': return 'danger';
      default: return 'primary';
    }
  };

  const allTestsPassed = Object.values(tests).every(test => test.status === 'success');

  return (
    <>
      <Head title="System Test Page"></Head>
      <Content>
        <BlockHead size="sm">
          <BlockHeadContent>
            <BlockTitle tag="h3" page>
              System Health Test
            </BlockTitle>
            <p className="text-soft">
              Testing core functionality to ensure the application is working properly
            </p>
          </BlockHeadContent>
        </BlockHead>

        <Block>
          <Row className="g-gs">
            <Col xxl="6" xl="8">
              <div className="card card-stretch">
                <div className="card-inner">
                  <div className="d-flex align-items-center justify-content-between mb-4">
                    <h5 className="card-title">Test Results</h5>
                    <Button 
                      color="primary" 
                      size="sm" 
                      onClick={runTests}
                    >
                      <Icon name="reload"></Icon>
                      <span>Run Tests Again</span>
                    </Button>
                  </div>

                  <div className="test-results">
                    {Object.entries(tests).map(([testName, result]) => (
                      <div key={testName} className="test-item border-bottom pb-3 mb-3">
                        <div className="d-flex align-items-start">
                          <div className="me-3">
                            <Icon 
                              name={getStatusIcon(result.status)} 
                              className={`text-${getStatusColor(result.status)}`}
                            />
                          </div>
                          <div className="flex-grow-1">
                            <h6 className="mb-1 text-capitalize">
                              {testName.replace(/([A-Z])/g, ' $1').trim()}
                            </h6>
                            <p className="text-soft mb-0">
                              {result.message}
                            </p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className={`alert alert-${allTestsPassed ? 'success' : 'warning'} mt-4`}>
                    <Icon name={allTestsPassed ? 'check-circle' : 'alert-triangle'}></Icon>
                    <span className="ms-2">
                      {allTestsPassed 
                        ? 'All tests passed! Your RAS Dashboard is working properly.' 
                        : 'Some tests failed or returned warnings. Check the details above.'}
                    </span>
                  </div>
                </div>
              </div>
            </Col>

            <Col xxl="6" xl="4">
              <div className="card card-stretch">
                <div className="card-inner">
                  <h5 className="card-title mb-3">Environment Info</h5>
                  <ul className="list-group list-group-flush">
                    <li className="list-group-item d-flex justify-content-between px-0">
                      <span>Current URL:</span>
                      <span className="text-soft">{window.location.origin}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between px-0">
                      <span>Hostname:</span>
                      <span className="text-soft">{window.location.hostname}</span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between px-0">
                      <span>Environment:</span>
                      <span className="text-soft">
                        {window.location.hostname.includes('replit.dev') ? 'Replit' : 
                         window.location.hostname === 'localhost' ? 'Local' : 'Production'}
                      </span>
                    </li>
                    <li className="list-group-item d-flex justify-content-between px-0">
                      <span>API Base URL:</span>
                      <span className="text-soft small">{buildApiUrl('')}</span>
                    </li>
                  </ul>
                </div>
              </div>

              <div className="card card-stretch mt-4">
                <div className="card-inner">
                  <h5 className="card-title mb-3">Quick Actions</h5>
                  <div className="d-grid gap-2">
                    <Button color="outline-primary" onClick={() => window.location.href = '/login'}>
                      <Icon name="sign-in"></Icon>
                      <span>Go to Login</span>
                    </Button>
                    <Button color="outline-primary" onClick={() => window.location.href = '/'}>
                      <Icon name="home"></Icon>
                      <span>Go to Dashboard</span>
                    </Button>
                    <Button 
                      color="outline-primary" 
                      onClick={() => window.open(buildApiUrl('/api-docs'), '_blank')}
                    >
                      <Icon name="book"></Icon>
                      <span>View API Docs</span>
                    </Button>
                  </div>
                </div>
              </div>
            </Col>
          </Row>
        </Block>
      </Content>
    </>
  );
};

export default TestPage;