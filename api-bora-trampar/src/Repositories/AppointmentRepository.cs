using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class AppointmentRepository(AppDbContext appDbContext) : IAppointmentRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            var list = await appDbContext.Appointments
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(a => (dynamic)new
            {
                id = a.Id,
                customer_id = a.CustomerId,
                profissional_id = a.ProfissionalId,
                date = a.Date,
                hour = a.Hour,
                createdAt = a.CreatedAt
            }).ToList();
        }

        public async Task<Appointment?> GetByIdAsync(string id)
        {
            return await appDbContext.Appointments.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Appointment?> CreateAsync(Appointment entity)
        {
            await appDbContext.Appointments.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Appointment?> UpdateAsync(Appointment entity)
        {
            await appDbContext.Appointments.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Appointment> DeleteAsync(Appointment entity)
        {
            await appDbContext.Appointments.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
