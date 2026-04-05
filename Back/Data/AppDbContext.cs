using Microsoft.EntityFrameworkCore;
using ApiGenericaCsharp.Modelos;

namespace ApiGenericaCsharp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Acreditacion> Acreditaciones { get; set; }
        public DbSet<RegistroCalificado> RegistrosCalificados { get; set; }
        public DbSet<ActivAcademica> ActividadesAcademicas { get; set; }
        public DbSet<Programa> Programas { get; set; }
        public DbSet<AaRc> AaRc { get; set; }
    }
}