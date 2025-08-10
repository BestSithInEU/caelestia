function fisher-update --description 'Update Fisher and all plugins'
    if not functions -q fisher
        echo "❌ Fisher not installed"
        return 1
    end
    
    echo "🔄 Updating Fisher and plugins..."
    
    # Update Fisher itself
    fisher update
    
    echo "✅ Fisher update complete!"
end