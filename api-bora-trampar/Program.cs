using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Configuration;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

Env.Load();

builder.Services.AddEndpointsApiExplorer();
builder.AddContext();
builder.AddBuilderServices();

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme    = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    string secretKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? "";
    string issuer    = Environment.GetEnvironmentVariable("JWT_ISSUER")     ?? "";
    string audience  = Environment.GetEnvironmentVariable("JWT_AUDIENCE")   ?? "";

    options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
    {
        ValidateIssuer           = true,
        ValidateAudience         = true,
        ValidateLifetime         = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer              = issuer,
        ValidAudience            = audience,
        ClockSkew                = TimeSpan.FromMinutes(5),
        IssuerSigningKey         = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
            System.Text.Encoding.UTF8.GetBytes(secretKey)
        )
    };

    // options.Events = new JwtBearerEvents
    // {
    //     OnMessageReceived = context =>
    //     {
    //         var accessToken = context.Request.Query["access_token"];
    //         var path        = context.HttpContext.Request.Path;

    //         if (!string.IsNullOrEmpty(accessToken) &&
    //             (path.StartsWithSegments("/hubs/notifications") ||
    //              path.StartsWithSegments("/hubs/chat")))
    //         {
    //             context.Token = accessToken;
    //         }

    //         return Task.CompletedTask;
    //     }
    // };
});

// Registra o filtro como Scoped (necessário para injeção de dependência)
// builder.Services.AddScoped<LoggerActionFilter>();

builder.Services.AddControllers(options =>
{
    // options.Filters.Add<LoggerActionFilter>();
})
.ConfigureApiBehaviorOptions(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(e => e.Value!.Errors.Count > 0)
            .Select(e => new {
                Field   = e.Key,
                Message = e.Value!.Errors.First().ErrorMessage,
                Order   = context.ActionDescriptor.Parameters
                    .SelectMany(p => p.ParameterType.GetProperties())
                    .FirstOrDefault(p => p.Name == e.Key)?
                    .GetCustomAttributes(typeof(DisplayAttribute), false)
                    .Cast<DisplayAttribute>()
                    .FirstOrDefault()?.Order ?? 999
            })
            .OrderBy(e => e.Order)
            .Select(e => new { e.Field, e.Message })
            .ToList();

        return new BadRequestObjectResult(new { errors });
    };
});


builder.Services.AddCors(options =>
{
    options.AddPolicy("AppPolicy", policy =>
        policy
            .SetIsOriginAllowed(_ => true)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseCors("AppPolicy");

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

var uploadPath = Path.Combine(builder.Environment.ContentRootPath, "wwwroot", "uploads");
if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();