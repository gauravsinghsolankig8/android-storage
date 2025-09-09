import React from 'react';
import { Box, Typography } from '@mui/material';

function HotelsPage() {
  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        Hotels Management
      </Typography>
      <Typography variant="body1">
        Manage hotel listings and information.
      </Typography>
    </Box>
  );
}

export default HotelsPage;