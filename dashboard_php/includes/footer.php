<?php
/**
 * Shared Layout Footer & Script Initializations
 */
?>
    </div> <!-- End .app-layout -->
    
    <!-- Leaflet.js Mapping -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    
    <!-- Core Firebase Configurations -->
    <script src="assets/js/firebase-config.js"></script>
    
    <!-- Dynamic Page Scripts Injections -->
    <?php if (isset($page_scripts) && is_array($page_scripts)): ?>
        <?php foreach ($page_scripts as $script): ?>
            <script src="<?php echo $script; ?>"></script>
        <?php endforeach; ?>
    <?php endif; ?>
</body>
</html>
