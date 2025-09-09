import React from 'react';
import { Box, Typography } from '@mui/material';

function ProductsPage() {
  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        Products Management
      </Typography>
      <Typography variant="body1">
        Manage spiritual store products and inventory.
      </Typography>
    </Box>
  );
}

export default ProductsPage;