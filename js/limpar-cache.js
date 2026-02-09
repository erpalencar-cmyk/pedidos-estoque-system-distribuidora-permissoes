// ======================================
// SCRIPT DE LIMPEZA DE CACHE AGRESSIVA
// ======================================
// 
// COMO USAR:
// 1. Abra seu app no navegador
// 2. Pressione F12 (abre DevTools)
// 3. Clique na aba "Console"
// 4. Copie o código abaixo
// 5. Cole no console e pressione ENTER
// 
// ======================================

(async function() {
  console.log('🚀 Iniciando limpeza agressiva de cache...\n');

  try {
    // ==========  PASSO 1: Limpar LocalStorage ==========
    console.log('1️⃣ Limpando LocalStorage...');
    try {
        if (typeof localStorage !== 'undefined' && localStorage) {
            localStorage.clear();
            console.log('✅ LocalStorage limpo\n');
        } else {
            console.warn('⚠️ localStorage não disponível, pulando...\n');
        }
    } catch (e) {
        console.warn('⚠️ Erro ao limpar localStorage:', e.message, '- continuando...\n');
    }

    // ========== PASSO 2: Limpar SessionStorage ==========
    console.log('2️⃣ Limpando SessionStorage...');
    try {
        if (typeof sessionStorage !== 'undefined' && sessionStorage) {
            sessionStorage.clear();
            console.log('✅ SessionStorage limpo\n');
        } else {
            console.warn('⚠️ sessionStorage não disponível, pulando...\n');
        }
    } catch (e) {
        console.warn('⚠️ Erro ao limpar sessionStorage:', e.message, '- continuando...\n');
    }

    // ========== PASSO 3: Limpar Google Analytics (se houver) ==========
    console.log('3️⃣ Limpando dados de análise...');
    if (window.gtag) {
      gtag('consent', 'update', {
        'analytics_storage': 'denied'
      });
    }
    console.log('✅ Dados de análise limpos\n');

    // ========== PASSO 4: Desregistrar Service Workers ==========
    console.log('4️⃣ Desregistrando Service Workers...');
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      for (let sw of registrations) {
        await sw.unregister();
        console.log(`✅ Service Worker desregistrado: ${sw.scope}`);
      }
    } else {
      console.log('ℹ️ Nenhum Service Worker encontrado');
    }
    console.log();

    // ========== PASSO 5: Limpar Cache da API ==========
    console.log('5️⃣ Limpando Cache da API...');
    if ('caches' in window) {
      const cacheNames = await caches.keys();
      for (let name of cacheNames) {
        await caches.delete(name);
        console.log(`✅ Cache deletado: ${name}`);
      }
    } else {
      console.log('ℹ️ Cache API não disponível');
    }
    console.log();

    // ========== PASSO 6: Limpar Cookies ==========
    console.log('6️⃣ Limpando Cookies...');
    document.cookie.split(';').forEach(c => {
      const eqPos = c.indexOf('=');
      const name = eqPos > -1 ? c.substr(0, eqPos).trim() : c.trim();
      document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
    });
    console.log('✅ Cookies limpos\n');

    // ========== RESULTADO ==========
    console.log('====================================');
    console.log('✅ LIMPEZA CONCLUÍDA COM SUCESSO!');
    console.log('====================================\n');

    // Aguardar 2 segundos e recarregar
    console.log('⏳ Recarregando página em 2 segundos...');
    await new Promise(r => setTimeout(r, 2000));
    
    console.log('🔄 Recarregando...\n');
    location.reload(true); // true = hard reload

  } catch (erro) {
    console.error('❌ Erro durante limpeza:', erro);
    console.log('\n💡 Mesmo com erro, pressione CTRL+SHIFT+R para hard refresh manual');
  }
})();

// ======================================
// Se precisar fazer à mão:
// ======================================
// localStorage.clear()
// sessionStorage.clear()
// location.reload(true)
// ======================================
