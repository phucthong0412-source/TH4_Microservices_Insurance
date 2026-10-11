#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/../.."
dotnet build ProductService.API
dotnet build PricingService.API
dotnet build PolicyService.API
dotnet build PaymentService.Api
dotnet build PolicySearchService.Api

dotnet build AgentPortalApiGateway/AgentPortalApiGateway
dotnet build AuthService
dotnet build ProductService
dotnet build PricingService
dotnet build PolicyService
dotnet build PaymentService
dotnet build PolicySearchService
dotnet build AuthService.Api

dotnet build ChatService.Api

dotnet build DashboardService.Api

dotnet build DocumentService.Api

dotnet build ChatService

dotnet build DashboardService

dotnet build DocumentService

dotnet build AuthService.Test

dotnet build ChatService.Test

dotnet build DashboardService.Test

dotnet build DocumentService.Test

dotnet build PolicySearchService.Test

dotnet build BlazorWasmClient/BlazorWasmClient
