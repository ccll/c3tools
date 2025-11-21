module c3tools::lsp;
import c3tools::ast;
import std::collections::list;
import std::collections::map;

<*
 Open .c3 source file LSP representation
*>
struct Document
{
    // document URI for LSP (acts as a hashmap key)
    String uri;

    // source code of a file (will be dynamically changing)
    DString source;

    // document version according to LSP protocol
    uint version;

    // Current document AST
    Ast ast;

    // LSP Project
    LspProject* proj;

    DynamicArenaAllocator _allocator;
}

struct DocumentContext {
    AstTypeDef* type;
    int expr_type; // assignment, call, typedef
    SymbolKind kind;
    String symbol;
}


fn Document new_document(String uri, String full_source, LspProject* proj)
{
    Document self = {
        .proj = proj,
    };

    // TODO: estimate average source size
    self._allocator.init(mem, 1024);

    // Allocate AST first, it will fill the arena with local metadata
    self.ast = ast::parse(full_source, file_path: uri, allc: &self._allocator);

    // append uri, because uri arg might be a short-lived object from json request
    self.uri = uri.copy(&self._allocator);

    // NOTE: source is allocated in heap, not in arena + add extra space for editing
    self.source.init(allocator: mem, capacity: full_source.len * 2);
    self.source.append(full_source);

    return self;
}

fn void? Document.save(&self, String full_sourse)
{
    // update full document structure?
    // trigger LspProject* document decls updates?

}

fn void? Document.change(&self, List{DocChange} changes)
{
    // update document scope structure

}

fn void Document.close(&self)
{
    // self.source has a separate allocator::heap()
    self.source.free();

    self._allocator.free();
}
