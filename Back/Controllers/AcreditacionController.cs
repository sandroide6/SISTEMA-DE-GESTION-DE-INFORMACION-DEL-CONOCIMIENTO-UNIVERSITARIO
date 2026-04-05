
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApiGenericaCsharp.Data;
using ApiGenericaCsharp.Modelos;

[ApiController]
[Route("api/[controller]")]
public class AcreditacionController : ControllerBase
{
    private readonly AppDbContext _context;

    public AcreditacionController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/acreditacion
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var data = await _context.Acreditaciones.ToListAsync();
        return Ok(data);
    }

    // GET: api/acreditacion/1
    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var item = await _context.Acreditaciones.FindAsync(id);
        if (item == null) return NotFound();

        return Ok(item);
    }

    // POST
    [HttpPost]
    public async Task<IActionResult> Create(Acreditacion model)
    {
        _context.Acreditaciones.Add(model);
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // PUT
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, Acreditacion model)
    {
        if (id != model.Resolucion)
            return BadRequest();

        _context.Entry(model).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // DELETE
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.Acreditaciones.FindAsync(id);
        if (item == null) return NotFound();

        _context.Acreditaciones.Remove(item);
        await _context.SaveChangesAsync();

        return Ok();
    }
}