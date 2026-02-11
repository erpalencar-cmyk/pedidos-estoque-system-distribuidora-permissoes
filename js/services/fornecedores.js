// =====================================================
// SERVIÇO DE FORNECEDORES
// =====================================================

// Listar fornecedores
async function listFornecedores(filters = {}) {
    try {
        // Garantir que window.supabase está pronto
        if (!window.supabase || typeof window.supabase.from !== 'function') {
            if (typeof aguardarClientePronto === 'function') {
                await aguardarClientePronto();
            } else {
                throw new Error('Cliente Supabase não disponível');
            }
        }
        
        let query = window.supabase
            .from('fornecedores')
            .select('*')
            .eq('ativo', true)
            .order('nome');

        if (filters.search) {
            query = query.or(`nome.ilike.%${filters.search}%,cnpj.ilike.%${filters.search}%`);
        }

        const { data, error } = await query;

        if (error) throw error;
        return data;
        
    } catch (error) {
        handleError(error, 'Erro ao listar fornecedores');
        return [];
    }
}

// Buscar fornecedor por ID
async function getFornecedor(id) {
    try {
        const { data, error } = await window.supabase
            .from('fornecedores')
            .select('*')
            .eq('id', id)
            .single();

        if (error) throw error;
        return data;
        
    } catch (error) {
        handleError(error, 'Erro ao buscar fornecedor');
        return null;
    }
}

// Criar fornecedor
async function createFornecedor(fornecedor) {
    try {
        showLoading(true);
        
        const { data, error } = await window.supabase
            .from('fornecedores')
            .insert([fornecedor])
            .select()
            .single();

        if (error) throw error;

        showToast('Fornecedor criado com sucesso!', 'success');
        return data;
        
    } catch (error) {
        handleError(error, 'Erro ao criar fornecedor');
        return null;
    } finally {
        showLoading(false);
    }
}

// Atualizar fornecedor
async function updateFornecedor(id, fornecedor) {
    try {
        showLoading(true);
        
        const { data, error } = await window.supabase
            .from('fornecedores')
            .update(fornecedor)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        showToast('Fornecedor atualizado com sucesso!', 'success');
        return data;
        
    } catch (error) {
        handleError(error, 'Erro ao atualizar fornecedor');
        return null;
    } finally {
        showLoading(false);
    }
}

// Excluir fornecedor
async function deleteFornecedor(id) {
    if (!confirm('Tem certeza que deseja excluir este fornecedor?')) {
        return false;
    }
    
    try {
        showLoading(true);
        
        const { error } = await window.supabase
            .from('fornecedores')
            .update({ ativo: false })
            .eq('id', id);

        if (error) throw error;

        showToast('Fornecedor excluído com sucesso!', 'success');
        return true;
        
    } catch (error) {
        handleError(error, 'Erro ao excluir fornecedor');
        return false;
    } finally {
        showLoading(false);
    }
}
