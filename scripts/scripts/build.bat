@echo off
pushd "%~dp0..\.."
call dotnet build ProductService.API
if errorlevel 1 exit /b %errorlevel%
call dotnet build PricingService.API
if errorlevel 1 exit /b %errorlevel%
call dotnet build PolicyService.API
if errorlevel 1 exit /b %errorlevel%
call dotnet build PaymentService.Api
if errorlevel 1 exit /b %errorlevel%
call dotnet build PolicySearchService.Api
if errorlevel 1 exit /b %errorlevel%

call dotnet build AgentPortalApiGateway/AgentPortalApiGateway
if errorlevel 1 exit /b %errorlevel%
call dotnet build AuthService
if errorlevel 1 exit /b %errorlevel%
call dotnet build ProductService
if errorlevel 1 exit /b %errorlevel%
call dotnet build PricingService
if errorlevel 1 exit /b %errorlevel%
call dotnet build PolicyService
if errorlevel 1 exit /b %errorlevel%
call dotnet build PaymentService
if errorlevel 1 exit /b %errorlevel%
call dotnet build PolicySearchService
if errorlevel 1 exit /b %errorlevel%

call dotnet build ProductService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet build PricingService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet build PolicyService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet build PaymentService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet test ProductService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test PricingService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test PolicyService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test PaymentService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet build AuthService.Api
if errorlevel 1 exit /b %errorlevel%

call dotnet build ChatService.Api
if errorlevel 1 exit /b %errorlevel%

call dotnet build DashboardService.Api
if errorlevel 1 exit /b %errorlevel%

call dotnet build DocumentService.Api
if errorlevel 1 exit /b %errorlevel%

call dotnet build ChatService
if errorlevel 1 exit /b %errorlevel%

call dotnet build DashboardService
if errorlevel 1 exit /b %errorlevel%

call dotnet build DocumentService
if errorlevel 1 exit /b %errorlevel%

call dotnet build AuthService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet build ChatService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet build DashboardService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet build DocumentService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet build PolicySearchService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test AuthService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test ChatService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test DashboardService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test DocumentService.Test
if errorlevel 1 exit /b %errorlevel%
call dotnet test PolicySearchService.Test
if errorlevel 1 exit /b %errorlevel%

call dotnet build BlazorWasmClient/BlazorWasmClient
if errorlevel 1 exit /b %errorlevel%

popd
